import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Limit, Snap } from '../types'

const BAR_CELLS = 10
const OK = '#4caf6a'
const WARN = '#d9a53a'
const BAD = '#e5534b'

const snap = atom({ plugin: 'limits-band', key: 'snap' } as const, {
  ctxWin: 0, limits: [], limitsAt: 0, now: 0,
} as Snap)

const tone = (pct: number) => (pct >= 90 ? BAD : pct >= 70 ? WARN : OK)

const tokens = (n: number) => (n >= 1e6 ? `${+(n / 1e6).toFixed(1)}M` : `${Math.round(n / 1e3)}k`)

const countdown = (ms: number) => {
  const m = Math.max(0, Math.ceil(ms / 60_000))
  const h = Math.floor(m / 60)
  if (h >= 24) return `${Math.floor(h / 24)}d${h % 24}h`
  if (h > 0) return `${h}h${String(m % 60).padStart(2, '0')}m`
  return `${m}m`
}

type Saved = { at: number; limits: Limit[] }
const parseSaved = (v: unknown): Saved | undefined => {
  const s = v as Saved | null
  return s && typeof s === 'object' && typeof s.at === 'number' && Array.isArray(s.limits) ? s : undefined
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const [now, usage, stored] = await Promise.all([$.clock.now(), $.session.usage(), $.store.get('limits')])
    // rateLimits は最初の応答まで空なので、他セッションが保存した値で埋める
    const saved = parseSaved(stored)
    await update($, snap, s => ({
      ...s,
      now,
      ctxPct: usage.context.percent,
      ctxTok: usage.context.tokens,
      ctxWin: usage.context.window,
      limits: usage.rateLimits.length ? usage.rateLimits : saved?.limits ?? s.limits,
      limitsAt: usage.rateLimits.length ? now : saved?.at ?? s.limitsAt,
    }))
    // session.measure は応答時しか来ないため、残り時間の表示は自前で進める
    $.clock.every(60_000, async () => {
      const [t, v] = await Promise.all([$.clock.now(), $.store.get('limits')])
      const newer = parseSaved(v)
      await update($, snap, s => (newer && newer.at > s.limitsAt
        ? { ...s, now: t, limits: newer.limits, limitsAt: newer.at }
        : { ...s, now: t }))
    })
    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    const now = await $.clock.now()
    const hasLimits = e.rateLimits.length > 0
    await update($, snap, s => ({
      ...s,
      now,
      ctxPct: e.context.percent,
      ctxTok: e.context.tokens,
      ctxWin: e.context.window,
      limits: hasLimits ? e.rateLimits : s.limits,
      limitsAt: hasLimits ? now : s.limitsAt,
    }))
    if (hasLimits && e.changed.includes('rateLimits')) {
      await $.store.set('limits', { at: now, limits: e.rateLimits } satisfies Saved)
    }
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)

    const s = await read($, snap)
    const { Box, Text } = $.ui.resolve(e)

    const cell = (label: string, pct: number, sub: string) => {
      // 1% でも 1 マスは塗る。0 マスだと「未使用」と見分けがつかない
      const filled = pct > 0 ? Math.max(1, Math.min(BAR_CELLS, Math.round((pct / 100) * BAR_CELLS))) : 0
      const color = tone(pct)
      return (
        <Text key={label}>
          <Text bold>{label} </Text>
          <Text color={color}>{'█'.repeat(filled)}</Text>
          <Text dimColor>{'░'.repeat(BAR_CELLS - filled)}</Text>
          <Text bold color={color}> {Math.round(pct)}%</Text>
          {sub ? <Text dimColor> {sub}</Text> : null}
        </Text>
      )
    }

    const limit = (label: string, kind: string) => {
      const l = s.limits.find(x => x.kind === kind)
      if (!l) return null
      const resetIn = l.resetsAt ? Date.parse(l.resetsAt) - s.now : undefined
      // リセット時刻を過ぎた保存値は古い。次の応答が来るまで 0% として扱う
      if (resetIn !== undefined && resetIn <= 0) return cell(label, 0, '')
      return cell(label, l.percentUsed, resetIn === undefined ? '' : `(${countdown(resetIn)})`)
    }

    const ctxSub = s.ctxWin ? `${s.ctxTok === undefined ? '-' : tokens(s.ctxTok)}/${tokens(s.ctxWin)}` : ''

    return (
      <Box flexDirection="row" justifyContent="space-between" paddingX={1}>
        {cell('ctx', s.ctxPct ?? 0, ctxSub)}
        {limit('5h', 'five_hour')}
        {limit('7d', 'seven_day')}
      </Box>
    )
  })
}
