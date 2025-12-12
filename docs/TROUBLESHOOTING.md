# Troubleshooting Guide

This guide covers common issues and solutions.

---

## 🔴 Setup Errors

### "sudo: password is required"

**Problem:** Setup script asks for sudo password repeatedly.

**Solution:**
```bash
# Check your sudo access
sudo -l

# If you don't have sudo, ask your admin to add you
# For some systems, you may need to cache sudo:
sudo -v
```

Then run setup again with the password ready.

---

### "dnf: command not found" or "Package not found"

**Problem:** DNF fails to find or install a package.

**Solution:**
```bash
# Update package lists
sudo dnf update -y

# Search for the package
dnf search package-name

# Try installing manually
sudo dnf install package-name
```

If still failing, the package may not exist in Fedora repos. Check:
- [Fedora Packages](https://packages.fedoraproject.org/)
- [RPMFusion](https://rpmfusion.org/) for non-standard packages

---

### "curl: command not found"

**Problem:** `curl` is required but not installed.

**Solution:**
```bash
sudo dnf install curl
```

Then run setup again.

---

### "Permission denied" when running setup

**Problem:** `bash setup_fedora.sh` says permission denied.

**Solution:**
```bash
# Make script executable
chmod +x setup_fedora.sh

# Run again
bash setup_fedora.sh
```

---

## 🟡 Installation Issues

### "Node.js not found after setup"

**Problem:** `node --version` says command not found.

**Solution:**
1. Restart your shell:
   ```bash
   exec $SHELL
   ```

2. Check if node is actually installed:
   ```bash
   which node
   npm --version
   ```

3. If still missing, Node setup may have failed. Check log:
   ```bash
   cat /tmp/setup_fedora_*.log | grep -A 5 "Node.js"
   ```

---

### "conda: command not found"

**Problem:** Miniforge installed but `conda` not found.

**Solution:**
1. Restart shell:
   ```bash
   exec $SHELL
   ```

2. Initialize conda:
   ```bash
   ~/miniforge/bin/conda init bash
   exec $SHELL
   ```

3. Verify:
   ```bash
   conda --version
   ```

---

### "pnpm: command not found"

**Problem:** pnpm installed but not in PATH.

**Solution:**
```bash
# Check if corepack enabled
sudo corepack enable

# Prepare pnpm
sudo corepack prepare pnpm@latest --activate

# Verify
pnpm --version
```

---

## 🔵 Verification Failures

### "Transformers library available" - FAILED

**Problem:** Verification failed for Python ML libraries.

**Solution:**
These libraries are optional. If you don't need them, ignore the failure.

If you want them:
```bash
# Activate venv (if used)
source ~/.venv/bin/activate

# Install manually
pip install transformers torch

# Re-run verification
bash verify_dev_environment.sh
```

---

### "Docker/Podman" - FAILED

**Problem:** Container runtime not working.

**Solution:**
```bash
# Check if podman is running
podman --version

# For Docker, start daemon
sudo systemctl start docker
sudo systemctl enable docker

# Test
podman run --rm hello-world
```

---

### "PostgreSQL connection refused"

**Problem:** Postgres installed but can't connect.

**Solution:**
```bash
# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create your user database
sudo -u postgres createuser --superuser $USER
createdb $USER

# Test connection
psql -U $USER -d $USER
```

If `.psql_history` permission error:
```bash
chmod 0600 ~/.psql_history
```

---

### "Redis connection refused"

**Problem:** Redis installed but can't connect.

**Solution:**
```bash
# Start Redis
sudo systemctl start redis
sudo systemctl enable redis

# Test
redis-cli ping
# Should output: PONG
```

---

## 🟢 Post-Setup Issues

### "Port 3000/5173 already in use"

**Problem:** Can't start dev server (port in use).

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port
npm run dev -- --port 3001
```

---

### "Git credentials not saving"

**Problem:** Git keeps asking for password.

**Solution:**
```bash
# Store credentials locally
git config --global credential.helper store

# Or use SSH instead
git config --global url."git@github.com:".insteadOf "https://github.com/"
# Make sure SSH key is added to GitHub: https://github.com/settings/keys
```

---

### "Can't write to /usr/local"

**Problem:** Permission denied when trying to install globally.

**Solution:**
```bash
# Don't use sudo with npm/pnpm
npm install -g package  # ❌ Don't do this with sudo

# Instead, use pnpm (handles permissions better)
pnpm add -g package
```

---

## 🔍 Debugging

### How to check setup logs

```bash
# Full log
cat /tmp/setup_fedora_*.log

# Last 50 lines
tail -50 /tmp/setup_fedora_*.log

# Search for errors
grep -i "error\|failed\|✗" /tmp/setup_fedora_*.log
```

### How to check verification logs

```bash
# Full verification report
cat verification_report/report.json | jq .

# Specific check
cat verification_report/logs/git_version.log

# All failed checks
ls verification_report/logs/*.log | while read f; do
  status=$(cat "$f" | head -1)
  echo "$f: $status"
done
```

### Check system info

```bash
# Fedora version
cat /etc/os-release

# Disk space
df -h

# RAM
free -h

# Installed packages
dnf list installed | grep -i package-name
```

---

## 🚀 Advanced Troubleshooting

### Completely clean reinstall

If setup is broken and you want to start fresh:

```bash
# Remove all installed tools (use with caution!)
sudo dnf remove git node python postgresql docker podman redis

# Remove Miniforge
rm -rf ~/miniforge

# Run setup again
bash setup_fedora.sh
```

### Run setup with debug output

```bash
# Run with set -x for verbose output
bash -x setup_fedora.sh 2>&1 | tee debug.log

# Review debug.log for details
cat debug.log
```

---

## 📞 Still Stuck?

1. **Check the full log:** `/tmp/setup_fedora_*.log`
2. **Search existing issues:** [GitHub Issues](https://github.com/yourusername/fedora-dev-setup/issues)
3. **Create a new issue** with:
   - OS version: `cat /etc/os-release`
   - Error message from log
   - What you were doing when it failed
4. **Ask for help:** [GitHub Discussions](https://github.com/yourusername/fedora-dev-setup/discussions)

---

## 📚 Related Resources

- [Fedora Docs](https://docs.fedoraproject.org/)
- [DNF Docs](https://dnf.readthedocs.io/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Podman Docs](https://docs.podman.io/)
- [Node.js Docs](https://nodejs.org/docs/)
- [Python Docs](https://docs.python.org/3/)

---

**Still need help?** Open an issue or discussion on GitHub!
