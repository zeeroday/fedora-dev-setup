# Quick Start for Beginners

Welcome! This guide walks you through the **3 simple steps** to set up your complete development environment.

---

## 📋 Before You Start

✅ **Do you have:**
- Fedora 43+ installed?
- Internet connection?
- At least 4GB RAM?
- 10GB free disk space?
- Sudo access (can run `sudo` commands)?

If yes, let's go! If no, see the [main README](README.md) for requirements.

---

## Step 1️⃣: Download & Run Setup

Open a terminal and run:

```bash
# Download this repo
git clone https://github.com/yourusername/fedora-dev-setup.git
cd fedora-dev-setup

# Run the setup script
bash fedora_setup/setup_fedora.sh
```

**What happens:**
- Script checks what's already installed
- Asks for your sudo password (needed for system packages)
- Installs Git, Node.js, Python, Docker, Postgres, Redis, linters, tools
- Takes about 10-15 minutes
- Creates a log file: `/tmp/setup_fedora_*.log`

**💡 Tip:** The script is **idempotent** — safe to run multiple times. It won't reinstall things.

---

## Step 2️⃣: Restart Your Shell

After setup completes, restart your shell to load new PATH variables:

```bash
exec $SHELL
```

Verify everything loaded:
```bash
git --version      # Should show git 2.x+
node --version     # Should show v20.x+
python --version   # Should show Python 3.x+
conda --version    # Should show conda 25.x+
```

---

## Step 3️⃣: Verify Installation

Run the verification script to check everything works:

```bash
cd fedora_setup
bash verify_dev_environment.sh
```

**Expected output:**
```
✓ PASSED: 30/30 checks
🎉 ALL CHECKS PASSED! Your environment is ready to go!
```

**If something failed:**
1. Check the detailed logs:
   ```bash
   cat verification_report/logs/failing_check.log
   ```
2. See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for solutions

---

## 🎉 You're Done!

Your development environment is ready. Here's what you can do now:

### Create a Website (Node.js)
```bash
pnpm create vite my-website --template react
cd my-website
pnpm install
pnpm dev
# Visit http://localhost:5173
```

### Create a Python App
```bash
conda create -n my-project python=3.11
conda activate my-project
pip install flask pandas
```

### Test Containers
```bash
podman run --rm hello-world
```

### Connect to Databases
```bash
# PostgreSQL
psql -U $USER -d $USER

# Redis
redis-cli ping
```

---

## 📚 Next Steps

- **Want to learn more?** See [docs/POST_SETUP.md](docs/POST_SETUP.md)
- **Running into issues?** Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Curious how it works?** Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Full details?** See [README.md](README.md)

---

## ❓ Common Questions

**Q: What if the setup fails?**
A: Check the log file `/tmp/setup_fedora_*.log` for error messages. Most issues are network-related or missing sudo access.

**Q: Can I interrupt the setup?**
A: Yes, it's safe. The script is idempotent, so you can run it again and it will skip already-installed components.

**Q: Do I need to be online the whole time?**
A: Yes, the script downloads packages from the internet. If it pauses, your connection may have dropped.

**Q: I don't use all these tools, can I skip some?**
A: Yes! Edit `fedora_setup/setup_fedora.sh` and comment out phases you don't need.

**Q: How do I uninstall everything?**
A: The script doesn't create an uninstaller. Most tools are in standard repos and can be removed with `sudo dnf remove <package>`.

---

## 🆘 Get Help

- **Found a bug?** [Open an issue](https://github.com/yourusername/fedora-dev-setup/issues)
- **Have questions?** [Start a discussion](https://github.com/yourusername/fedora-dev-setup/discussions)
- **Want to contribute?** See [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Happy coding!** 🚀

Questions? Start with the [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) guide.
