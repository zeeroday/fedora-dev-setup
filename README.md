# 🚀 Fedora Developer Environment Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Fedora 43+](https://img.shields.io/badge/Fedora-43%2B-blue)](https://fedoraproject.org/)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-green)](https://www.gnu.org/software/bash/)
[![Status: Production Ready](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)]()

A **one-command setup** for junior and senior developers to get a complete, production-ready development environment on **Fedora Linux**.

✨ **Tired of manual setup?** This script automates everything in 10-15 minutes.

---

## 🎯 What Gets Installed

| Component | Purpose | Version |
|-----------|---------|---------|
| **Git** | Version control | Latest |
| **Node.js** | JavaScript runtime | 20+ |
| **pnpm** | Fast package manager | Latest |
| **Python** | Interpreter & package manager | 3.11+ (Miniforge) |
| **Podman** | Container runtime (OCI) | 5.0+ |
| **Docker** | Container runtime (alternative) | Latest |
| **PostgreSQL** | Relational database | 15+ |
| **Redis** | In-memory cache | 8.0+ |
| **VSCode** | Code editor | Latest |
| **ESLint** | JS/TS linter | Latest |
| **Prettier** | Code formatter | Latest |
| **Black** | Python formatter | Latest |
| **Ruff** | Python linter | Latest |
| **Starship** | Shell prompt | Latest |
| **fzf** | Fuzzy finder | Latest |
| **ripgrep** | Fast grep | Latest |
| **bat** | Modern cat | Latest |

### Installation Phases

The setup runs in 9 sequential phases (~10-15 minutes):

1. **Base System** - System updates, compilers, shell tools (gcc, tmux, zsh, fzf, ripgrep)
2. **Git & SSH** - Version control, SSH key generation, GitHub CLI
3. **VSCode** - Code editor with Microsoft repository
4. **Node.js & pnpm** - JavaScript runtime and fast package manager
5. **Python (Miniforge)** - Conda-based Python distribution for data science/ML
6. **Containers** - Podman (daemonless) + Docker CE (optional)
7. **Databases** - PostgreSQL + Redis with auto-start services
8. **Linters** - ESLint, Prettier, Black, Ruff for code quality
9. **Shell Tools** - Starship prompt for enhanced terminal experience

Each phase checks if components exist before installing (idempotent design).

📖 **[Full Installation Details](docs/INSTALLATION_DETAILS.md)** - Complete breakdown of what gets installed and why

---

## ⚡ Quick Start (3 Steps)

### Step 1: Clone & Run
```bash
# Clone this repo
git clone https://github.com/yourusername/fedora-dev-setup.git
cd fedora-dev-setup

# Run the setup (requires sudo for system packages)
bash fedora_setup/setup_fedora.sh
```

### Step 2: Restart Shell
```bash
exec $SHELL
```

### Step 3: Verify Installation
```bash
bash fedora_setup/verify_dev_environment.sh
```

**Expected output:** ✓ PASSED: 30/30 checks 🎉

---

## 📋 Requirements

- **OS:** Fedora 43+ (Workstation or Server)
- **RAM:** 4GB minimum (8GB+ recommended)
- **Disk:** 10GB free space
- **Internet:** Required for package downloads
- **Sudo access:** Required for system packages

---

## 🤔 Is This For Me?

✅ **Perfect if you:**
- Just installed Fedora
- Want to avoid manual setup
- Need Node.js + Python + Containers ready
- Want linters and formatters pre-configured
- Are a beginner or returning developer

❌ **Not suitable if you:**
- Need GPU/NVIDIA CUDA setup (deferred to manual setup)
- Require specific Python versions (easily customizable)
- Want minimal bloat (this installs everything)

---

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** — Absolute beginner guide with screenshots
- **[docs/INSTALLATION_DETAILS.md](docs/INSTALLATION_DETAILS.md)** — Complete breakdown of what gets installed
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Common issues and fixes
- **[docs/POST_SETUP.md](docs/POST_SETUP.md)** — What to do after setup
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — How the scripts work

---

## 🔧 What the Scripts Do

### `setup_fedora.sh`
Idempotent setup script that:
- Upgrades system packages
- Installs dev tools (git, curl, jq, etc.)
- Configures SSH keys
- Installs Node.js + pnpm
- Installs Python + Miniforge
- Sets up Podman + Docker
- Configures PostgreSQL + Redis
- Installs linters and formatters
- Installs shell enhancements

**Safety:** Script checks if components already exist (idempotent). Safe to run multiple times.

### `verify_dev_environment.sh`
Comprehensive verification that:
- Checks system info
- Verifies all tools are installed
- Tests database connections
- Validates linters and formatters
- Generates JSON report
- Creates detailed logs

**Output:** `verification_report/report.json` + `verification_report/logs/`

---

## 🚀 Getting Started After Setup

### Create a Web Project
```bash
pnpm create vite my-app --template react
cd my-app
pnpm install
pnpm dev
# Open http://localhost:5173
```

### Create a Python Project
```bash
conda create -n ml-dev python=3.11
conda activate ml-dev
pip install flask pandas numpy
```

### Test Containers
```bash
podman run --rm hello-world
podman run -d -p 5432:5432 postgres:15
```

### Connect to Databases
```bash
# PostgreSQL
psql -U $USER -d $USER

# Redis
redis-cli ping
```

---

## ⚙️ Customization

Edit `fedora_setup/setup_fedora.sh` to:
- Skip components (comment out phases)
- Change versions (Node 20 → 18, Python 3.11 → 3.12)
- Add/remove packages
- Customize shell config

Example: To skip Docker installation, comment out Phase 6:
```bash
# log "--- Phase 6: Container runtimes (Podman + Docker) ---"
# ... (comment out the entire phase)
```

---

## 🐛 Troubleshooting

**Setup fails with "sudo password required"?**
```bash
sudo -l  # Check your sudo access
```

**Verification shows failures?**
```bash
cat verification_report/logs/failing_check.log
```

**Miniforge not found after setup?**
```bash
exec $SHELL  # Restart shell to reload PATH
conda --version
```

**More help?** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 📊 Performance

| Phase | Time | Notes |
|-------|------|-------|
| System packages | 3-5 min | Internet speed dependent |
| Node.js + tools | 2-3 min | Quick downloads |
| Python + Miniforge | 3-5 min | ~700MB download |
| Databases | 2-3 min | Small, fast setup |
| Verification | ~1 min | Fast smoke tests |
| **Total** | **10-15 min** | One-time cost |

---

## 🤝 Contributing

Found an issue? Have improvements? See [CONTRIBUTING.md](CONTRIBUTING.md)

We welcome:
- Bug reports
- Feature requests
- Documentation improvements
- Script optimizations
- Platform support (Fedora Server, ARM64, etc.)

---

## 📝 License

MIT License — See [LICENSE](LICENSE)

---

## 🙋 FAQ

**Q: Is this production-ready?**
A: Yes. Verified on Fedora 43 Workstation. Idempotent and safe to run multiple times.

**Q: Can I skip components?**
A: Yes. Edit `setup_fedora.sh` and comment out phases you don't need.

**Q: What if setup fails?**
A: Check `/tmp/setup_fedora_*.log` for detailed error messages.

**Q: Does this work on Fedora Server?**
A: Yes. The script has no desktop dependencies.

**Q: Can I run this remotely (SSH)?**
A: Yes, but you'll need to handle sudo prompts. Use `ssh -t` or configure passwordless sudo.

**Q: What about GPU support?**
A: NVIDIA drivers and CUDA are deferred to manual setup (platform-specific). See docs/POST_SETUP.md for links.

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/fedora-dev-setup/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/fedora-dev-setup/discussions)
- **Docs:** [docs/](docs/)

---

## 🎓 Learning Resources

After setup, explore:
- **Node.js:** [nodejs.org/docs](https://nodejs.org/docs)
- **Python:** [python.org/docs](https://docs.python.org/3/)
- **Containers:** [podman.io/docs](https://docs.podman.io/)
- **Databases:** [postgresql.org](https://www.postgresql.org/docs/), [redis.io](https://redis.io/documentation/)
- **Git:** [git-scm.com](https://git-scm.com/doc)

---

## 🌟 Star History

If this helped you, please ⭐ this repo!

---

**Created:** December 2025  
**Fedora Version:** 43+  
**Maintainer:** [Your Name/Team]  
**Last Updated:** December 12, 2025
