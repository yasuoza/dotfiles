#!/bin/bash

sanitize_osc_field() {
    printf '%s' "${1-}" \
        | tr '\r\n' '  ' \
        | sed \
            -e 's/[[:cntrl:]]//g' \
            -e 's/;/,/g' \
            -e 's/[[:space:]][[:space:]]*/ /g' \
            -e 's/^ //' \
            -e 's/ $//'
}

send_osc777_notification() {
    local title="${1-}"
    local message="${2-}"
    local client_session=""
    local pane_tty=""

    # Hooks may run without a controlling terminal (for example in a
    # background session). When tmux is available, write to the focused pane
    # of the most recently active client instead.
    if command -v tmux >/dev/null 2>&1; then
        client_session=$(tmux list-clients -F '#{client_activity} #{client_session}' 2>/dev/null \
            | sort -rn | head -n 1 | sed 's/^[^ ]* //' || true)
        if [[ -n "$client_session" ]]; then
            pane_tty=$(tmux display-message -p -t "${client_session}:" '#{pane_tty}' 2>/dev/null || true)
        fi
    fi

    if [[ -n "$pane_tty" && -w "$pane_tty" ]]; then
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$title" "$message" > "$pane_tty" 2>/dev/null || true
        return 0
    fi

    if [[ ! -w /dev/tty ]]; then
        return 0
    fi

    if [[ -n ${TMUX:-} ]]; then
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$title" "$message" > /dev/tty 2>/dev/null || true
    else
        printf '\e]777;notify;%s;%s\a' "$title" "$message" > /dev/tty 2>/dev/null || true
    fi
}
