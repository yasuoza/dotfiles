#!/usr/bin/env bash
# pretooluse-guard.sh - Security guard for Claude Code bypass permissions mode
#
# Design philosophy:
#   - Maximum productivity: normal dev workflows are never blocked
#   - Guard the perimeter: block secrets exfiltration, destructive ops, system persistence
#   - .env reads are ALLOWED (docker-compose compatibility)
#   - Not a perfect sandbox - defense in depth for common & high-impact threats
#
# Testing:
#   ルールを変更したら必ずテストを実行すること。
#   bash ~/dotfiles/claude/scripts/hooks/tests/test-pretooluse-guard.sh
#
# References:
#   - Flatt Security "Pwning Claude Code in 8 Different Ways"
#   - Anthropic engineering sandboxing guide
#   - OWASP AI Agent Security Cheat Sheet
#   - Check Point CVE-2025-59536 (config self-modification)
#   - Community hooks: sgasser, Mandalorian007, kornysietsma

set -euo pipefail

# stdin is consumed once - store it
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# ================================================================
# BASH COMMAND GUARDS
# ================================================================
if [[ "$TOOL_NAME" == "Bash" ]]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

  # ---- Network: raw socket tools (no legitimate dev use) ----
  if echo "$CMD" | grep -qE '\b(nc|ncat|netcat|socat|telnet)\b'; then
    deny "Raw socket tools (nc/netcat/socat/telnet) are blocked for security."
  fi

  # ---- Network: pipe-to-shell (download & execute) ----
  if echo "$CMD" | grep -qE '(curl|wget)\s.*\|\s*(ba)?sh\b'; then
    deny "pipe-to-shell pattern (curl/wget | sh) is blocked. Download then inspect."
  fi

  # ---- Network: tunnel / expose local ports ----
  if echo "$CMD" | grep -qE '\b(ngrok|cloudflared|bore)\b'; then
    deny "Tunnel/expose tools (ngrok/cloudflared/bore) are blocked."
  fi

  # ---- Network: reverse shell patterns ----
  if echo "$CMD" | grep -qE 'bash\s+-i\s+>&\s*/dev/tcp'; then
    deny "Reverse shell pattern detected and blocked."
  fi
  if echo "$CMD" | grep -qE 'python[23]?\s.*\bsocket\b.*\bconnect\b'; then
    deny "Python reverse shell pattern detected and blocked."
  fi
  if echo "$CMD" | grep -qE 'python[23]?\s+-m\s+http\.server'; then
    deny "Starting HTTP server to expose local files is blocked."
  fi
  if echo "$CMD" | grep -qE '\bphp\s+-S\b'; then
    deny "Starting PHP built-in server is blocked."
  fi

  # ---- Exfiltration: sensitive dirs + network combo ----
  if echo "$CMD" | grep -qE '(\.ssh|\.aws|\.gnupg|\.kube|\.docker/config).*\b(curl|wget|scp|sftp|rsync)\b'; then
    deny "Sending credential files over network is blocked."
  fi
  if echo "$CMD" | grep -qE '\b(curl|wget|scp|sftp|rsync)\b.*(\.ssh|\.aws|\.gnupg|\.kube|\.docker/config)'; then
    deny "Sending credential files over network is blocked."
  fi

  # ---- Exfiltration: base64 encoding of secrets ----
  if echo "$CMD" | grep -qE 'base64.*(\.ssh|\.aws|\.gnupg|\.kube)'; then
    deny "Encoding credential files with base64 is blocked."
  fi
  if echo "$CMD" | grep -qE '(\.ssh|\.aws|\.gnupg|\.kube).*base64'; then
    deny "Encoding credential files with base64 is blocked."
  fi

  # ---- Git: destructive operations ----
  if echo "$CMD" | grep -qE 'git\s+push\s+.*--force-with-lease\b'; then
    : # --force-with-lease is safer, allow it
  elif echo "$CMD" | grep -qE 'git\s+push\s+.*(-f\b|--force\b)'; then
    deny "git push --force is blocked. Use --force-with-lease on feature branches."
  fi
  if echo "$CMD" | grep -qE 'git\s+reset\s+--hard'; then
    deny "git reset --hard is blocked. Use git stash or git checkout <file>."
  fi
  if echo "$CMD" | grep -qE 'git\s+clean\s+-[a-zA-Z]*[dfx]'; then
    deny "git clean with -d/-f/-x is blocked. Remove untracked files manually."
  fi
  if echo "$CMD" | grep -qE 'git\s+config\s+--(global|system)'; then
    deny "Modifying global/system git config is blocked."
  fi
  if echo "$CMD" | grep -qE 'git\s+(filter-branch|filter-repo)\b'; then
    deny "Git history rewriting commands are blocked."
  fi
  if echo "$CMD" | grep -qE 'git\s+reflog\s+expire'; then
    deny "git reflog expire is blocked."
  fi

  # ---- Filesystem: mass destruction ----
  if echo "$CMD" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*\s+(/\s|/$|~|\.\./)'; then
    deny "Recursive rm on /, ~, or parent directories is blocked."
  fi
  if echo "$CMD" | grep -qE '\b(dd\s+if=.*/dev/|mkfs\.|fdisk|parted)\b'; then
    deny "Disk/partition modification commands are blocked."
  fi
  if echo "$CMD" | grep -qE '\bshred\b'; then
    deny "shred (irrecoverable file destruction) is blocked."
  fi
  if echo "$CMD" | grep -qE ':\(\)\s*\{.*:\|:'; then
    deny "Fork bomb detected and blocked."
  fi

  # ---- Privilege escalation ----
  if echo "$CMD" | grep -qE '(^|\s|;|&&|\|)\s*sudo\b'; then
    deny "sudo is blocked in automated mode."
  fi
  if echo "$CMD" | grep -qE 'chmod\s+([0-7]*7{3}|a\+rwx|[ug]\+s)\b'; then
    deny "Dangerous chmod (777/setuid/setgid) is blocked."
  fi

  # ---- System persistence ----
  if echo "$CMD" | grep -qE '(^|\s|;|&&)\s*crontab\b'; then
    deny "crontab modification is blocked."
  fi
  if echo "$CMD" | grep -qE '\b(launchctl|systemctl)\s+(load|enable|start)\b'; then
    deny "Service installation/enabling is blocked."
  fi

  # ---- Shell config modification via redirection ----
  if echo "$CMD" | grep -qE '>\s*~/\.(bashrc|zshrc|profile|bash_profile|zprofile)'; then
    deny "Redirecting output to shell config files is blocked."
  fi

  # ---- Sneaky bypass techniques (Flatt Security research) ----
  if echo "$CMD" | grep -qE 'sort\s+--compress-program'; then
    deny "sort --compress-program (code execution vector) is blocked."
  fi
  if echo "$CMD" | grep -qE 'man\s+--html='; then
    deny "man --html= (code execution vector) is blocked."
  fi
  if echo "$CMD" | grep -qE '\brg\s+--pre='; then
    deny "rg --pre= (code execution vector) is blocked."
  fi
  if echo "$CMD" | grep -qE "\bsed\b.*['\"]s/.*/.*/e"; then
    deny "sed with /e flag (code execution vector) is blocked."
  fi
fi

# ================================================================
# READ GUARDS - protect credentials outside project
# ================================================================
if [[ "$TOOL_NAME" == "Read" ]]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

  # SSH keys and config
  if echo "$FILE" | grep -qE '/\.ssh/(id_|known_hosts|authorized_keys|config)'; then
    deny "Reading SSH keys/config is blocked."
  fi

  # Cloud credentials
  if echo "$FILE" | grep -qE '/\.aws/(credentials|config)$'; then
    deny "Reading AWS credentials is blocked."
  fi
  if echo "$FILE" | grep -qE '/\.config/gcloud/'; then
    deny "Reading GCloud credentials is blocked."
  fi
  if echo "$FILE" | grep -qE '/\.kube/config$'; then
    deny "Reading kubeconfig is blocked."
  fi
  if echo "$FILE" | grep -qE '/\.docker/config\.json$'; then
    deny "Reading Docker registry auth is blocked."
  fi

  # Auth tokens and credentials
  if echo "$FILE" | grep -qE '/\.git-credentials$'; then
    deny "Reading git-credentials is blocked."
  fi
  if echo "$FILE" | grep -qE '/\.netrc$'; then
    deny "Reading .netrc is blocked."
  fi
  if echo "$FILE" | grep -qE '/\.(npmrc|pypirc)$'; then
    deny "Reading package registry credentials is blocked."
  fi

  # Shell history (may contain secrets typed interactively)
  if echo "$FILE" | grep -qE '/\.(bash_history|zsh_history|sh_history)$'; then
    deny "Reading shell history is blocked."
  fi

  # Database credentials
  if echo "$FILE" | grep -qE '/\.(pgpass|my\.cnf)$'; then
    deny "Reading database credential files is blocked."
  fi

  # Terraform state (contains cloud secrets in plaintext)
  if echo "$FILE" | grep -qE '\.tfstate$'; then
    deny "Reading .tfstate (contains cloud secrets) is blocked."
  fi

  # NOTE: .env files are intentionally ALLOWED for docker-compose compatibility
fi

# ================================================================
# WRITE / EDIT GUARDS - protect config and system files
# ================================================================
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

  # Claude Code settings (prevent self-modification / CVE-2025-59536)
  if echo "$FILE" | grep -qE '/\.claude/(settings\.json|settings\.local\.json)$'; then
    deny "Modifying Claude Code settings is blocked (self-modification prevention)."
  fi
  if echo "$FILE" | grep -qE '/\.claude\.json$'; then
    deny "Modifying Claude config is blocked."
  fi

  # Git hooks (persistence vector)
  if echo "$FILE" | grep -qE '/\.git/hooks/'; then
    deny "Writing to .git/hooks/ is blocked (persistence vector)."
  fi

  # Shell configs
  if echo "$FILE" | grep -qE '/\.(bashrc|zshrc|profile|bash_profile|zprofile)$'; then
    deny "Modifying shell configuration files is blocked."
  fi

  # SSH directory
  if echo "$FILE" | grep -qE '/\.ssh/'; then
    deny "Modifying SSH config/keys is blocked."
  fi

  # Cloud credential configs
  if echo "$FILE" | grep -qE '/\.(aws|kube)/'; then
    deny "Modifying cloud credential configs is blocked."
  fi
  if echo "$FILE" | grep -qE '/\.docker/config\.json$'; then
    deny "Modifying Docker registry auth is blocked."
  fi

  # Package registry configs (registry redirect attacks)
  if echo "$FILE" | grep -qE '/\.(npmrc|yarnrc|pypirc)$'; then
    deny "Modifying package registry configs is blocked."
  fi
fi

# ================================================================
# DEFAULT: ALLOW
# ================================================================
exit 0
