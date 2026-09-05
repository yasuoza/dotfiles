#!/bin/bash

# Return a value that is safe to use as an OSC 777 title or group.
sanitize_notification_field() {
    printf '%s' "${1-}" \
        | tr '\r\n' '  ' \
        | sed \
            -e 's/[[:cntrl:]]//g' \
            -e 's/;/,/g' \
            -e 's/[[:space:]][[:space:]]*/ /g' \
            -e 's/^ //' \
            -e 's/ $//'
}

# Resolve the Claude session name from the hook payload or its transcript.
# Stop and Notification payloads do not currently carry the session name, so
# custom-title records are read from the session's JSONL transcript.
resolve_claude_session_name() {
    local input="${1-}"
    local session_id="${2-}"
    local name=""
    local transcript_path=""
    local cwd=""
    local project_dir=""
    local candidate=""

    if [[ -n "$input" ]]; then
        name=$(printf '%s' "$input" | jq -r '
            .session_name
            // .sessionName
            // .session_title
            // .sessionTitle
            // empty
        ' 2>/dev/null || true)
    fi

    if [[ -n "$name" ]]; then
        printf '%s' "$name"
        return 0
    fi

    transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null || true)

    if [[ "$transcript_path" == \~/* ]]; then
        transcript_path="${HOME}/${transcript_path#\~/}"
    fi

    if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
        cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)
        if [[ -n "$cwd" && -n "$session_id" ]]; then
            # Claude's project directory names replace each slash with a dash.
            project_dir="${HOME}/.claude/projects/${cwd//\//-}"
            candidate="${project_dir}/${session_id}.jsonl"
            if [[ -f "$candidate" ]]; then
                transcript_path="$candidate"
            fi
        fi
    fi

    if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
        if [[ -n "$session_id" ]]; then
            name=$(jq -r --arg sid "$session_id" '
                select(.type == "custom-title"
                    and ((.sessionId // .session_id // "") == $sid))
                | (.customTitle // .custom_title // empty)
            ' "$transcript_path" 2>/dev/null | tail -n 1 || true)
            # Older transcripts may not carry sessionId on metadata records;
            # transcript_path already identifies the session in that case.
            if [[ -z "$name" ]]; then
                name=$(jq -r '
                    select(.type == "custom-title")
                    | (.customTitle // .custom_title // empty)
                ' "$transcript_path" 2>/dev/null | tail -n 1 || true)
            fi
        else
            name=$(jq -r '
                select(.type == "custom-title")
                | (.customTitle // .custom_title // empty)
            ' "$transcript_path" 2>/dev/null | tail -n 1 || true)
        fi

        if [[ -n "$name" ]]; then
            printf '%s' "$name"
            return 0
        fi
    fi

    return 0
}
