#!/bin/bash

INPUT=$(cat)
PROJECT_NAME=$(basename $(echo "$INPUT" | jq -r '.cwd'))
REASON=$(echo "$INPUT" | jq -r '.reason')

terminal-notifier \
    -title "✅ Task Completed" \
    -subtitle "${PROJECT_NAME}" \
    -message "Reason: ${REASON}" \
    -sound "default" \
    -group "claude-code-stop-notification-#${PROJECT_NAME}"
