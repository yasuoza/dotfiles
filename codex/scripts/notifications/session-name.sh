#!/bin/bash

# Resolve the Codex session name from the hook/notify payload and the local
# session index. The index is append-only, so the last matching record is the
# current name after a rename.
resolve_codex_session_name() {
    local input="${1-}"
    local name=""
    local session_id=""
    local index_path="${CODEX_HOME:-$HOME/.codex}/session_index.jsonl"

    name=$(printf '%s' "$input" | jq -r '
        .session_name
        // .sessionName
        // .thread_name
        // .threadName
        // empty
    ' 2>/dev/null || true)
    if [[ -n "$name" ]]; then
        printf '%s' "$name"
        return 0
    fi

    session_id=$(printf '%s' "$input" | jq -r '
        .session_id
        // .["thread-id"]
        // .thread_id
        // empty
    ' 2>/dev/null || true)
    if [[ -z "$session_id" || ! -r "$index_path" ]]; then
        return 0
    fi

    jq -r --arg id "$session_id" '
        select((.id // "") == $id)
        | (.thread_name // .threadName // empty)
    ' "$index_path" 2>/dev/null | tail -n 1 || true
}
