#!/usr/bin/env bash
# Idempotent Fedora development environment setup for senior developers
# Supports: Git, VSCode, Node.js, Python, containers, databases, linting, and dotfiles
set -u

LOGFILE="/tmp/setup_fedora_$(date +%s).log"
echo "Logging to $LOGFILE"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

run() {
  log ">> $*"
  if "$@" >> "$LOGFILE" 2>&1; then
    log "✓ $1 success"
    return 0
  else
    log "✗ $1 failed (see $LOGFILE)"
    return 1
  fi
}

log "╔══════════════════════════════════════════════════════════════════╗"
log "║                                                                  ║"
log "║    🚀 Fedora Development Environment Setup                      ║"
log "║       Complete setup for senior developers                      ║"
log "║                                                                  ║"
log "╚══════════════════════════════════════════════════════════════════╝"
log ""
log "📋 This setup will install:"
log "   • Git & SSH configuration"
log "   • Node.js 20 + pnpm"
log "   • Python 3.11+ (Miniforge)"
log "   • Container runtimes (Podman & Docker)"
log "   • Databases (PostgreSQL & Redis)"
log "   • Linters & formatters (ESLint, Prettier, Black, Ruff)"
log "   • Shell tools (Starship, fzf, ripgrep, bat)"
log ""
log "⏱️  Estimated time: 10-15 minutes"
log "📝 Log: $LOGFILE"
log ""

# ============================================================================
# 1. System packages & dev tools
# ============================================================================
# ============================================================================
# 1. System packages & dev tools
# ============================================================================
log ""
log "┌─ Phase 1/9: Base system packages ─────────────────────────────┐"
run sudo dnf upgrade --refresh -y
run sudo dnf install -y git curl wget unzip make gcc gcc-c++ kernel-headers kernel-devel \
  zsh tmux util-linux-user which procps-ng openssh-clients jq fzf ripgrep bat

# ============================================================================
# 2. Git & SSH
# ============================================================================
# ============================================================================
# 2. Git & SSH
# ============================================================================
log "┌─ Phase 2/9: Git and SSH ──────────────────────────────────────┐"
run sudo dnf install -y gh || log "gh (GitHub CLI) not available in repo, skipping"

# Generate SSH key if missing
if [ ! -f ~/.ssh/id_ed25519 ]; then
  log "Generating SSH key..."
  run ssh-keygen -t ed25519 -C "dev@laptop" -f ~/.ssh/id_ed25519 -N ""
else
  log "SSH key already exists"
fi

# Set git config (non-interactive; edit manually if needed)
if ! git config --global user.name | grep -q .; then
  run git config --global user.name "Developer"
  run git config --global user.email "dev@localhost"
fi

# ============================================================================
# 3. VSCode (optional, non-blocking)
# ============================================================================
# ============================================================================
# 3. VSCode (optional, non-blocking)
# ============================================================================
log "┌─ Phase 3/9: VSCode ───────────────────────────────────────────┐"
if ! command -v code &>/dev/null; then
  log "Installing VSCode..."
  run sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
  run bash -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo' || true
  run sudo dnf check-update || true
  run sudo dnf install -y code || log "VSCode install failed, continuing"
else
  log "VSCode already installed"
fi

# ============================================================================
# 4. Node.js & pnpm
# ============================================================================
# ============================================================================
# 4. Node.js & pnpm
# ============================================================================
log "┌─ Phase 4/9: Node.js and pnpm ────────────────────────────────┐"
if ! command -v node &>/dev/null; then
  log "Installing Node.js..."
  run bash -c 'curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -'
  run sudo dnf install -y nodejs
else
  log "Node.js already installed: $(node --version)"
fi

# pnpm setup (requires sudo for symlinks in /usr/bin)
if ! command -v pnpm &>/dev/null; then
  log "Setting up pnpm (requires sudo)..."
  run sudo corepack enable || log "corepack enable failed"
  run sudo corepack prepare pnpm@latest --activate || log "corepack prepare failed"
else
  log "pnpm already available: $(pnpm --version)"
fi

# ============================================================================
# 5. Python & Miniforge
# ============================================================================
# ============================================================================
# 5. Python & Miniforge
# ============================================================================
log "┌─ Phase 5/9: Python (Miniforge) ───────────────────────────────┐"
if ! command -v conda &>/dev/null; then
  log "Installing Miniforge..."
  curl -fsSL -o /tmp/Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
  run bash /tmp/Miniforge3.sh -b -p "$HOME/miniforge"
  export PATH="$HOME/miniforge/bin:$PATH"
  run conda init bash || true
  log "Added Miniforge to PATH; you may need to restart shell"
else
  log "Miniforge already installed"
fi

# ============================================================================
# 6. Container runtimes
# ============================================================================
# ============================================================================
# 6. Container runtimes
# ============================================================================
log "┌─ Phase 6/9: Container runtimes (Podman + Docker) ─────────────┐"
if ! command -v podman &>/dev/null; then
  log "Installing Podman..."
  run sudo dnf install -y podman buildah skopeo
else
  log "Podman already installed"
fi

# Optional: Docker CE (non-blocking)
if ! command -v docker &>/dev/null; then
  log "Installing Docker CE (optional)..."
  run sudo dnf install -y dnf-plugins-core || true
  run sudo curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo || true
  run sudo dnf install -y docker-ce docker-ce-cli containerd.io || log "Docker install failed, continuing with Podman"
  run sudo systemctl enable --now docker || log "Docker daemon may not be running"
else
  log "Docker already installed"
fi

# ============================================================================
# 7. Databases (local dev)
# ============================================================================
# ============================================================================
# 7. Databases (local dev)
# ============================================================================
log "┌─ Phase 7/9: Local databases (Postgres + Redis) ────────────────┐"
if ! command -v psql &>/dev/null; then
  log "Installing PostgreSQL..."
  run sudo dnf install -y postgresql-server postgresql-contrib
  run sudo postgresql-setup --initdb || log "PostgreSQL setup may have already run"
  run sudo systemctl enable --now postgresql || true
  # Create user db for current user
  run bash -c 'sudo -u postgres createuser --superuser "$USER" 2>/dev/null || true'
  run bash -c 'createdb "$USER" 2>/dev/null || true'
else
  log "PostgreSQL already installed"
fi

if ! command -v redis-cli &>/dev/null; then
  log "Installing Redis..."
  run sudo dnf install -y redis
  run sudo systemctl enable --now redis || true
else
  log "Redis already installed"
fi

# ============================================================================
# 8. Linters & formatters
# ============================================================================
# ============================================================================
# 8. Linters & formatters
# ============================================================================
log "┌─ Phase 8/9: Linters and formatters ───────────────────────────┐"
if command -v pnpm &>/dev/null; then
  log "Installing global JS tooling..."
  run pnpm add -g eslint prettier || log "pnpm global add failed"
else
  log "pnpm not available; skipping global JS tools"
fi

if command -v pip &>/dev/null; then
  log "Installing Python tooling..."
  run pip install --upgrade black ruff isort || log "Python tooling install failed"
else
  log "pip not available; skipping Python tools"
fi

# ============================================================================
# 9. Shell enhancements & dotfiles
# ============================================================================
# ============================================================================
# 9. Shell enhancements & dotfiles
# ============================================================================
log "┌─ Phase 9/9: Shell and dotfiles ───────────────────────────────┐"
if ! command -v starship &>/dev/null; then
  log "Installing Starship..."
  run bash -c 'curl -fsSL https://starship.rs/install.sh | sudo sh -s -- -y' || log "Starship install failed"
else
  log "Starship already installed"
fi

# Change shell to zsh (optional; uncomment if desired)
# log "Setting zsh as default shell..."
# run chsh -s $(which zsh) || log "chsh failed; set manually with: chsh -s $(which zsh)"

log ""
log "╔══════════════════════════════════════════════════════════════════╗"
log "║                    ✓ Setup Complete!                            ║"
log "╚══════════════════════════════════════════════════════════════════╝"
log ""
log "📝 Log saved to: $LOGFILE"
log ""
log "🎯 Next Steps (in order):"
log "   1. Restart your shell:"
log "      exec \$SHELL"
log ""
log "   2. Verify installation:"
log "      bash ~/fedora_setup/verify_dev_environment.sh"
log ""
log "   3. Configure Git (if not done):"
log "      git config --global user.name 'Your Name'"
log "      git config --global user.email 'you@example.com'"
log ""
log "   4. Add SSH key to GitHub:"
log "      cat ~/.ssh/id_ed25519.pub"
log "      → https://github.com/settings/keys"
log ""
log "   5. Test containers:"
log "      podman run --rm hello-world"
log ""
log "   6. Test databases:"
log "      psql -U \$USER -d \$USER"
log "      redis-cli ping"
log ""
log "📚 For more info, check the SETUP_GUIDE.md in fedora_setup/"
log ""
