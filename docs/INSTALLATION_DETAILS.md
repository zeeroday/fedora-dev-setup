# Installation Details

This document provides a complete breakdown of what `setup_fedora.sh` installs and why. The script runs in 9 sequential phases, each checking if components exist before installing (idempotent design).

## Overview

- **Execution Time:** 10-15 minutes
- **Design:** Idempotent (safe to run multiple times)
- **Error Handling:** Non-blocking for optional components
- **Logging:** All output saved to `/tmp/setup_fedora_*.log`

---

## Phase 1: Base System Packages

**What Gets Installed:**
- System updates (dnf upgrade)
- Development tools: `gcc`, `gcc-c++`, `make`, `kernel-headers`, `kernel-devel`
- Version control: `git`
- Network utilities: `curl`, `wget`
- Archive tools: `unzip`
- Shell tools: `zsh`, `tmux`, `util-linux-user`
- Process utilities: `which`, `procps-ng`
- SSH client: `openssh-clients`
- Data tools: `jq` (JSON processor)
- Search/grep tools: `fzf`, `ripgrep`, `bat`

**Why:**
These form the foundation for all development work. Compilers enable building native extensions for Python/Node.js packages. Shell tools provide modern alternatives to standard Unix utilities.

**Idempotency:**
Uses `dnf install -y` which skips already-installed packages.

---

## Phase 2: Git & SSH

**What Gets Installed:**
- GitHub CLI (`gh`) - for repository management
- SSH key generation (ed25519, if missing)
- Git global configuration (user.name, user.email)

**Why:**
Git and SSH are essential for version control and secure authentication with GitHub/GitLab. The ed25519 key type is modern, secure, and widely supported.

**Idempotency:**
- Checks for existing SSH key at `~/.ssh/id_ed25519`
- Checks if git config already set before configuring
- Uses non-interactive defaults (manually edit later if needed)

**Security Notes:**
- SSH key generated with empty passphrase for convenience
- Default git config uses placeholder values ("Developer", "dev@localhost")
- **Action required:** Add SSH public key to GitHub and update git config

---

## Phase 3: VSCode (Visual Studio Code)

**What Gets Installed:**
- Microsoft repository GPG key
- VSCode repository configuration
- VSCode editor package

**Why:**
Industry-standard code editor with excellent extensions for all languages and frameworks installed in this setup.

**Non-blocking:**
This phase continues even if VSCode installation fails (e.g., repo unavailable, user preference for other editors).

**Idempotency:**
Checks if `code` command exists before installing.

---

## Phase 4: Node.js & pnpm

**What Gets Installed:**
- Node.js v20 LTS (from NodeSource repository)
- pnpm package manager (via corepack)

**Why:**
- Node.js: JavaScript runtime for web development, build tools, and modern frontend frameworks
- pnpm: Fast, disk-efficient alternative to npm with better dependency management

**Technical Details:**
- Uses NodeSource repository for latest Node.js LTS
- Corepack enables pnpm without separate installation
- Requires sudo for symlink creation in `/usr/bin`

**Idempotency:**
- Checks for existing `node` and `pnpm` commands
- Reports current versions if already installed

---

## Phase 5: Python (Miniforge)

**What Gets Installed:**
- Miniforge3 (conda/mamba distribution)
- Python 3.12+ with conda package manager
- Conda initialization for bash shell

**Why:**
- Miniforge provides conda with default conda-forge channel
- Better for data science, ML/AI work than system Python
- Conda manages both Python packages and system-level dependencies
- Mamba (fast conda alternative) included by default

**Installation Location:**
`$HOME/miniforge/` (user-local, no sudo required)

**Idempotency:**
Checks if `conda` command exists before downloading installer.

**Shell Integration:**
Adds conda initialization to `~/.bashrc` (restart shell to activate).

---

## Phase 6: Container Runtimes

**What Gets Installed:**

### Podman (Primary)
- `podman` - Container runtime (Docker-compatible)
- `buildah` - Container image builder
- `skopeo` - Container image operations

### Docker CE (Optional)
- `docker-ce` - Docker Engine
- `docker-ce-cli` - Docker CLI
- `containerd.io` - Container runtime
- Docker systemd service (enabled and started)

**Why:**
- **Podman:** Daemonless, rootless containers. Fedora's recommended container runtime.
- **Docker:** Industry standard, some tools still require it specifically
- **Both:** Having both ensures compatibility with all container workflows

**Non-blocking:**
Docker installation failures don't stop setup (Podman is sufficient for most use cases).

**Idempotency:**
- Checks for `podman` and `docker` commands separately
- Skips installation if already present

**Security:**
Podman runs rootless by default (better security). Docker requires adding user to `docker` group for rootless (manual step).

---

## Phase 7: Databases (Local Development)

**What Gets Installed:**

### PostgreSQL
- `postgresql-server` - Database server
- `postgresql-contrib` - Additional extensions
- Database initialization
- Systemd service (enabled, auto-start on boot)
- Superuser role for current user
- Database named after current user

### Redis
- `redis` - In-memory data store
- Systemd service (enabled, auto-start on boot)

**Why:**
Essential databases for web development and data work:
- PostgreSQL: Powerful relational database
- Redis: Fast caching, session storage, pub/sub

**Initial Setup:**
- Creates superuser PostgreSQL role: `$USER`
- Creates default database: `$USER`
- Both services start automatically on boot

**Idempotency:**
- Checks for `psql` and `redis-cli` commands
- Database creation uses `2>/dev/null || true` to ignore "already exists" errors

**Connection:**
```bash
# PostgreSQL
psql -U $USER -d $USER

# Redis
redis-cli ping
```

---

## Phase 8: Linters & Formatters

**What Gets Installed:**

### JavaScript/TypeScript
- `eslint` - JavaScript/TypeScript linter
- `prettier` - Code formatter
- Installed globally via pnpm

### Python
- `black` - Opinionated code formatter
- `ruff` - Fast Python linter (Rust-based)
- `isort` - Import statement sorter
- Installed via pip

**Why:**
Code quality and consistency tools used by most professional development teams. Pre-installed to save setup time on new projects.

**Non-blocking:**
Failures in this phase don't stop setup (nice-to-have tools).

**Idempotency:**
- Checks if pnpm/pip available before attempting installation
- Package managers handle reinstallation gracefully

---

## Phase 9: Shell Enhancements

**What Gets Installed:**
- Starship prompt - Modern, fast, customizable shell prompt

**Why:**
Starship provides rich context (git branch, Python/Node versions, command duration) directly in your prompt, improving terminal productivity.

**Features:**
- Shows current directory, git status
- Displays active language versions (Python, Node.js)
- Command execution time
- Exit status indicators

**Activation:**
Add to `~/.bashrc` or `~/.zshrc`:
```bash
eval "$(starship init bash)"  # or zsh
```

**Optional:**
Script includes commented-out `chsh` command to switch default shell to zsh.

---

## Installation Order Rationale

The phases are ordered by **dependency and criticality**:

1. **System packages first** - Required for everything else
2. **Git/SSH early** - Needed for cloning repos during setup
3. **VSCode before languages** - Can download extensions during language installation
4. **Node.js before Python** - Faster installation
5. **Containers after languages** - May need compilers for container builds
6. **Databases after containers** - Can run in containers if local install fails
7. **Linters after languages** - Require Node.js/Python to be installed
8. **Shell last** - Cosmetic, least critical

---

## Error Handling Strategy

### Non-blocking Components
These can fail without stopping setup:
- VSCode (phase 3)
- Docker CE (phase 6) - Podman is sufficient
- Global linters (phase 8)
- Starship prompt (phase 9)

### Critical Components
These will show errors but script continues:
- System packages (phase 1) - Manual intervention required
- Git/SSH (phase 2) - Essential for development
- Node.js/Python (phases 4-5) - Core languages

### Logging
All operations logged to `/tmp/setup_fedora_*.log`:
- Timestamped entries
- Success/failure indicators (✓/✗)
- Full command output for debugging

---

## Post-Installation Steps

After setup completes:

1. **Restart shell** - Activate conda, load new PATH
   ```bash
   exec $SHELL
   ```

2. **Verify installation** - Run verification script
   ```bash
   bash ~/fedora_setup/verify_dev_environment.sh
   ```

3. **Configure Git** - Update placeholder values
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

4. **Add SSH to GitHub**
   ```bash
   cat ~/.ssh/id_ed25519.pub
   # Copy and add to: https://github.com/settings/keys
   ```

5. **Test containers**
   ```bash
   podman run --rm hello-world
   ```

6. **Test databases**
   ```bash
   psql -U $USER -d $USER
   redis-cli ping
   ```

---

## Disk Space Requirements

Approximate space needed:

| Component | Size |
|-----------|------|
| System packages | ~500 MB |
| VSCode | ~300 MB |
| Node.js | ~200 MB |
| Miniforge (Python) | ~500 MB |
| Docker CE | ~200 MB |
| PostgreSQL | ~100 MB |
| Redis | ~10 MB |
| **Total** | **~2 GB** |

Actual usage will grow with package installations in Node.js and Python environments.

---

## Network Requirements

The script downloads from:
- Fedora repositories (dnf packages)
- Microsoft repositories (VSCode)
- NodeSource repository (Node.js)
- GitHub releases (Miniforge)
- Docker repository (Docker CE)
- Starship installer (GitHub)

**Bandwidth estimate:** 1-2 GB download

---

## Security Considerations

### Repository Trust
- Microsoft and NodeSource repos use GPG key verification
- Docker repo uses signed packages
- Miniforge downloaded directly from GitHub releases

### Sudo Requirements
Required only for:
- System package installation (dnf)
- VSCode repo configuration
- Docker service management
- PostgreSQL user creation
- Starship installation

### SSH Key
- Generated without passphrase for convenience
- **Recommendation:** Add passphrase later with `ssh-keygen -p`

### Service Exposure
- PostgreSQL listens on localhost only by default
- Redis listens on localhost only by default
- Docker socket requires group membership

---

## Customization

### Skip Components
Comment out entire phases you don't need:
```bash
# Skip Docker CE installation
# log "┌─ Phase 6/9: Container runtimes..."
# if ! command -v docker &>/dev/null; then
#   ...
# fi
```

### Change Versions
Modify repository URLs:
```bash
# Use Node.js 18 instead of 20
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
```

### Different Python
Use standard Anaconda instead of Miniforge:
```bash
# Replace Miniforge URL
curl -fsSL -o /tmp/Anaconda3.sh https://repo.anaconda.com/archive/Anaconda3-latest-Linux-x86_64.sh
```

---

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions to common issues.

**Quick checks:**

```bash
# View setup log
tail -50 /tmp/setup_fedora_*.log

# Check what failed
grep "✗" /tmp/setup_fedora_*.log

# Verify installations
bash ~/fedora_setup/verify_dev_environment.sh
```

---

## Comparison with Manual Installation

**Manual setup time:** 2-3 hours  
**Script setup time:** 10-15 minutes  
**Time saved:** ~2 hours

**Advantages:**
- Consistent, repeatable setup
- Idempotent (safe to re-run)
- Logged for troubleshooting
- Tested configuration
- No missed dependencies

---

## Related Documentation

- [README.md](../README.md) - Overview and quick start
- [QUICK_START.md](../QUICK_START.md) - Step-by-step guide for beginners
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [POST_SETUP.md](POST_SETUP.md) - What to do after installation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical design and maintenance
