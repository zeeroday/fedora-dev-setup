# How It Works - Architecture & Design

This document explains the design, structure, and implementation of the Fedora dev setup scripts.

---

## 🏗️ Architecture Overview

```
User
  ↓
setup_fedora.sh (Installation)
  ├─ System packages (dnf)
  ├─ Git & SSH
  ├─ Node.js + pnpm
  ├─ Python + Miniforge
  ├─ Containers (Podman/Docker)
  ├─ Databases (PostgreSQL/Redis)
  ├─ Linters & formatters
  └─ Shell tools
       ↓
   Installation Complete
       ↓
verify_dev_environment.sh (Verification)
  ├─ System checks
  ├─ Tool availability
  ├─ Version checks
  ├─ Connection tests
  └─ JSON report generation
       ↓
verification_report/
  ├─ report.json (structured results)
  └─ logs/ (detailed per-tool logs)
       ↓
   User has ready dev environment
```

---

## 🔧 Setup Script (`setup_fedora.sh`)

### Design Principles

1. **Idempotent** — Safe to run multiple times (checks before installing)
2. **Non-blocking** — Failures in optional components don't break setup
3. **Logged** — All output goes to `/tmp/setup_fedora_*.log`
4. **Clear feedback** — Each phase shows status (✓ success / ✗ failed)

### Script Structure

```bash
# Main functions
log()    # Output with timestamp
run()    # Execute command + log result

# 9 Installation Phases
Phase 1: System packages (git, curl, jq, fzf, ripgrep, bat, etc.)
Phase 2: Git & SSH setup (key generation, git config)
Phase 3: VSCode (optional, non-blocking)
Phase 4: Node.js 20 + pnpm
Phase 5: Python 3.11+ (Miniforge)
Phase 6: Container runtimes (Podman + Docker)
Phase 7: Databases (PostgreSQL + Redis)
Phase 8: Linters & formatters
Phase 9: Shell enhancements (Starship)
```

### How Idempotency Works

Each phase checks if a tool exists before installing:

```bash
if ! command -v node &>/dev/null; then
  log "Installing Node.js..."
  run sudo dnf install -y nodejs
else
  log "Node.js already installed: $(node --version)"
fi
```

**Benefits:**
- Run setup multiple times safely
- Re-run only failed phases
- No duplicate installations
- Respects manual customizations

### Error Handling

```bash
run() {
  log ">> $*"
  if "$@" >> "$LOGFILE" 2>&1; then
    log "✓ $1 success"
    return 0
  else
    log "✗ $1 failed (see $LOGFILE)"
    return 1  # Non-blocking — continues
  fi
}
```

**Key aspect:** Failures don't stop setup. Optional components can fail without blocking essential ones.

---

## ✅ Verification Script (`verify_dev_environment.sh`)

### Design Principles

1. **Comprehensive** — Checks all installed components
2. **Structured output** — JSON report for parsing
3. **Detailed logging** — Per-tool logs for debugging
4. **User-friendly** — Clear pass/fail summary

### Script Structure

```bash
check() {
  # 1. Run command
  # 2. Capture output + status
  # 3. Create temp JSON
  # 4. Merge into report.json
  # 5. Cleanup
}

# 30 Checks across 6 categories
System & Hardware (5)
Git & SSH (3)
Node.js & pnpm (3)
Python & Miniforge (2)
Containers (3)
Databases (2)
Linters & Formatters (4)
VSCode (1)
Shell & Tools (5)
Python ML (optional, 2)
```

### Check Flow

```
For each check:
  1. Run command: "$@" > logfile
  2. Capture status (pass/fail)
  3. Create JSON:
     {
       "check_name": {
         "description": "...",
         "status": "pass|fail",
         "log_file": "path",
         "log": "output"
       }
     }
  4. Merge with existing report.json
  5. Generate summary with counts
```

### Report Generation

Each check produces a JSON entry:

```json
{
  "node_version": {
    "description": "Node.js version",
    "status": "pass",
    "log_file": "verification_report/logs/node_version.log",
    "log": "v20.19.6\n"
  }
}
```

Final report aggregates all checks:

```bash
jq '.[] | select(.status == "pass") | length'  # Count passes
jq '.[] | select(.status == "fail") | length'  # Count failures
```

---

## 📂 Directory Structure

```
fedora-dev-setup/
├── README.md                      # Main documentation
├── QUICK_START.md                 # Beginner guide
├── CONTRIBUTING.md                # Contribution guide
├── LICENSE                        # MIT license
├── .gitignore                     # Ignore temp files
│
├── fedora_setup/
│   ├── setup_fedora.sh            # Main setup script (500+ lines)
│   ├── verify_dev_environment.sh  # Verification script (300+ lines)
│   ├── verification_report/       # Generated after first verification
│   │   ├── report.json            # Structured results
│   │   └── logs/                  # Per-tool logs (30+ files)
│   │       ├── git_version.log
│   │       ├── node_version.log
│   │       ├── postgres.log
│   │       └── ... (one per check)
│   │
│   └── docs/
│       ├── TROUBLESHOOTING.md     # Common issues & fixes
│       ├── POST_SETUP.md          # What to do next
│       ├── ARCHITECTURE.md        # This file
│       └── README.md              # Index of docs
│
└── .github/
    └── workflows/
        └── test.yml               # GitHub Actions CI (optional)
```

---

## 🔐 Security Considerations

### SSH Key Generation

```bash
ssh-keygen -t ed25519 \
  -C "dev@laptop" \
  -f ~/.ssh/id_ed25519 \
  -N ""
```

**Why ed25519?**
- Modern, secure elliptic curve algorithm
- Smaller keys than RSA
- Faster verification
- Better than aging RSA-2048

### Sudo Usage

Only used for:
- System package installation (`dnf install`)
- Database daemon startup (`systemctl enable/start`)
- Corepack activation (manages pnpm)

**Philosophy:** Minimize sudo, clearly log when used

### No Hardcoded Secrets

- No API keys
- No credentials in logs
- User handles GitHub SSH setup manually
- Database password set by user

---

## 🧪 Testing Strategy

### Manual Testing

```bash
# Fresh Fedora 43 VM
# Run setup
bash setup_fedora.sh

# Verify
bash verify_dev_environment.sh

# Spot checks
node --version
python --version
git --version
podman version
psql --version
redis-cli --version
```

### Idempotency Testing

```bash
# Run twice in a row
bash setup_fedora.sh
bash setup_fedora.sh

# Should skip already-installed components
```

### Verification Testing

```bash
# Should report 30/30 checks passing
bash verify_dev_environment.sh
```

### Optional: GitHub Actions CI

```yaml
# .github/workflows/test.yml
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    container: fedora:43
    steps:
      - uses: actions/checkout@v3
      - run: bash fedora_setup/setup_fedora.sh
      - run: bash fedora_setup/verify_dev_environment.sh
```

---

## 🎯 Design Decisions & Rationale

### Why Bash?

**Chosen:** Bash shell scripts
**Alternatives considered:** Python, Go, Docker

**Why Bash?**
- Runs on any Linux system
- No additional dependencies
- Direct access to system tools
- Easy to understand and modify
- Standard in sysadmin workflows

### Why DNF (not Fedora)?

- Fedora's native package manager
- Automatically handles repos
- Safer than manual installs
- Updates integrated

### Why Miniforge (not Anaconda)?

- Lighter weight (~800MB vs 2GB)
- Conda-forge by default (more packages)
- Community-driven
- Better for development environments

### Why Podman + Docker?

- Podman: default container runtime on Fedora
- Docker: widest industry adoption
- Both installed for flexibility
- No lock-in to one ecosystem

### Why Separate Verification Script?

- Setup and verification are different concerns
- Can re-run verification without setup
- Easier to test individual components
- Better for CI/CD pipelines

---

## 🔄 Maintenance & Updates

### Adding a New Phase

1. Copy an existing phase (e.g., Phase 4)
2. Change section number and name
3. Add 3-5 checks using `run` function
4. Update documentation
5. Test idempotency

### Updating Versions

Edit `setup_fedora.sh`:

```bash
# Node.js 20 → 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -

# Python 3.11 → 3.12
# Miniforge automatically uses latest
```

### Debugging Failed Setup

```bash
# Check log
tail -100 /tmp/setup_fedora_*.log

# Re-run with debug output
bash -x setup_fedora.sh 2>&1 | tee debug.log
```

---

## 📊 Metrics & Reporting

### Verification Output

```
Total checks: 30
Passed: 30
Failed: 0
Success rate: 100%
```

### Log Files Generated

```
/tmp/setup_fedora_1765503588.log    # Setup log
verification_report/report.json      # Verification report
verification_report/logs/            # 30 detailed logs
```

### Performance Metrics

```
Setup time: ~10-15 minutes
  - System packages: 3-5 min
  - Node.js: 2-3 min
  - Python/Miniforge: 3-5 min
  - Databases: 2-3 min
  - Verification: ~1 min

Report generation: <1 second
```

---

## 🚀 Future Improvements

**Planned:**
- [ ] Configuration file (`.fedora-setup.yml`)
- [ ] Interactive installer
- [ ] Skip-component flags
- [ ] Auto-update functionality
- [ ] GPU setup (NVIDIA CUDA)
- [ ] Kubernetes (k3d) integration
- [ ] Language server installation

**Community contributions welcome!**

---

## 📚 Related Reading

- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide)
- [Fedora Documentation](https://docs.fedoraproject.org/)
- [DNF Documentation](https://dnf.readthedocs.io/)
- [jq Manual](https://stedolan.github.io/jq/manual/)

---

**Maintained by:** Your Team  
**Last Updated:** December 12, 2025
