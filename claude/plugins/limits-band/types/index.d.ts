export type Limit = { kind: string; percentUsed: number; resetsAt?: string }

export type Snap = {
  ctxPct?: number
  ctxTok?: number
  ctxWin: number
  limits: Limit[]
  limitsAt: number
  now: number
}

declare module 'claude-code' {
  interface PluginState {
    'limits-band': { snap: Snap }
  }
}
