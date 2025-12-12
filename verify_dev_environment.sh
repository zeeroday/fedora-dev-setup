#!/usr/bin/env bash
# Comprehensive dev environment verification script (FIXED)
# Produces JSON report and logs for all checks

set -euo pipefail

OUT_DIR="verification_report"
OUT_FILE="$OUT_DIR/report.json"
LOGDIR="$OUT_DIR/logs"

mkdir -p "$LOGDIR"
echo "{}" > "$OUT_FILE"

# Ensure `jq` is available early — needed to build the JSON report
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required by this script. Please install jq and rerun."
  exit 1
fi

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Helper: run check and record result (FIXED to use --rawfile)
check() {
  local name="$1"
  local desc="$2"
  shift 2
  local logfile="$LOGDIR/${name}.log"

  log "Running: $name"
  if "$@" >"$logfile" 2>&1; then
    status="pass"
  else
    status="fail"
  fi

  # Create a safe temporary file inside the report directory
  tmpfile=$(mktemp "$OUT_DIR/${name}.XXXXXX.json")

  # Use --arg for the log file path and --rawfile to capture the log contents
  jq -n \
    --arg n "$name" \
    --arg d "$desc" \
    --arg s "$status" \
    --rawfile l "$logfile" \
    --arg lf "$logfile" \
    '{($n): {description: $d, status: $s, log_file: $lf, log: $l}}' \
    > "$tmpfile"

  tmpout=$(mktemp "$OUT_DIR/report.XXXXXX.json")
  jq -s 'reduce .[] as $x ({}; . * $x)' "$OUT_FILE" "$tmpfile" > "$tmpout"
  mv "$tmpout" "$OUT_FILE"
  rm -f "$tmpfile"
}

log "╔════════════════════════════════════════════════════════════════╗"
log "║     Dev Environment Verification (Fedora Setup)                ║"
log "╚════════════════════════════════════════════════════════════════╝"
log "Report: $OUT_FILE"
log "Logs: $LOGDIR"
log ""

# ============================================================================
# System & Hardware
# ============================================================================
check "inventory" "System inventory (uname, CPU, memory)" uname -a
check "os_release" "OS release info" bash -c 'cat /etc/os-release'
check "cpu_info" "CPU details" lscpu
check "memory" "Memory (RAM + Swap)" free -h
check "disk" "Disk layout" lsblk

# ============================================================================
# Git & SSH
# ============================================================================
check "git_version" "Git version" git --version
check "git_config" "Git config (user)" bash -c 'git config --global user.name && git config --global user.email'
check "ssh_key" "SSH key present" test -f ~/.ssh/id_ed25519.pub

# ============================================================================
# Node.js & pnpm
# ============================================================================
check "node_version" "Node.js version" node --version
check "npm_version" "npm version" npm --version
check "pnpm_version" "pnpm version" pnpm --version

# ============================================================================
# Python & Miniforge
# ============================================================================
check "conda_version" "Conda/Miniforge version" bash -c 'conda --version'
check "python_version" "Python version" python --version

# ============================================================================
# Containers
# ============================================================================
check "podman_version" "Podman version" podman --version
check "docker_version" "Docker version" docker --version
# Do not swallow failures for the container smoke test
check "hello_world" "Container smoke test (hello-world)" bash -c 'podman run --rm hello-world >/dev/null 2>&1'

# ============================================================================
# Databases
# ============================================================================
check "psql_version" "PostgreSQL client version" psql --version
check "redis_version" "Redis/Valkey version" bash -c 'redis-cli --version || valkey-cli --version'

# ============================================================================
# Linters & Formatters
# ============================================================================
check "eslint" "ESLint available" bash -c 'command -v eslint >/dev/null || npm list -g eslint >/dev/null 2>&1'
check "prettier" "Prettier available" bash -c 'command -v prettier >/dev/null || npm list -g prettier >/dev/null 2>&1'
check "black" "Black (Python formatter)" python -m black --version
check "ruff" "Ruff (Python linter)" python -m ruff --version

# ============================================================================
# VSCode
# ============================================================================
check "vscode_version" "VSCode version" bash -c 'command -v code >/dev/null && code --version | head -n 1'

# ============================================================================
# Shell & Tools
# ============================================================================
check "zsh" "Zsh shell available" bash -c 'command -v zsh >/dev/null && zsh --version'
check "starship" "Starship prompt available" bash -c 'command -v starship >/dev/null && starship --version'
check "fzf" "fzf available" bash -c 'command -v fzf >/dev/null && fzf --version'
check "ripgrep" "ripgrep (rg) available" bash -c 'command -v rg >/dev/null && rg --version | head -n 1'
check "bat" "bat (cat replacement) available" bash -c 'command -v bat >/dev/null && bat --version'

# ============================================================================
# Python ML (optional)
# ============================================================================
check "transformers" "Transformers library available" bash -c 'if [ -d "$HOME/.venv" ]; then source "$HOME/.venv/bin/activate" && python -c "import transformers; print(transformers.__version__)"; else python -c "import transformers; print(transformers.__version__)"; fi'
check "torch" "PyTorch available" bash -c 'if [ -d "$HOME/.venv" ]; then source "$HOME/.venv/bin/activate" && python -c "import torch; print(torch.__version__)"; else python -c "import torch; print(torch.__version__)"; fi'

log ""
log "╔════════════════════════════════════════════════════════════════╗"
log "║                 Verification Results Summary                   ║"
log "╚════════════════════════════════════════════════════════════════╝"
log ""

# Count passes and failures
passes=$(jq '[.[] | select(.status == "pass")] | length' "$OUT_FILE" 2>/dev/null || echo 0)
fails=$(jq '[.[] | select(.status == "fail")] | length' "$OUT_FILE" 2>/dev/null || echo 0)
total=$((passes + fails))

log "   ✓ PASSED: $passes/$total checks"
if [ "$fails" -gt 0 ]; then
  log "   ✗ FAILED: $fails/$total checks"
  log ""
  log "   Failed checks:"
  jq -r '.[] | select(.status == "fail") | "     ✗ \(.description)"' "$OUT_FILE" 2>/dev/null | head -20
else
  log ""
  log "   🎉 ALL CHECKS PASSED! Your environment is ready to go!"
fi

log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""
log "📂 REPORTS & LOGS"
log ""
log "   📊 Full Report:     $OUT_FILE"
log "   📋 Logs Directory:  $LOGDIR"
log ""
log "   💡 View results with:"
log "      cat $OUT_FILE | jq ."
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""
log "🚀 WHAT'S NEXT?"
log ""
log "   1️⃣  Your environment is verified!"
log ""
log "   2️⃣  Start coding:"
log "      • Clone a repo or create a new project"
log "      • Use Node.js/pnpm: pnpm create vite my-app"
log "      • Use Python: conda create -n my-env python=3.11"
log ""
log "   3️⃣  Test containers:"
log "      podman run --rm hello-world"
log ""
log "   4️⃣  Connect to databases:"
log "      psql -U \$USER -d \$USER    # PostgreSQL"
log "      redis-cli ping              # Redis"
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""
