# What's Next After Setup?

Your development environment is ready! Here's a guided path forward.

---

## 🎯 First Steps (Today)

### 1. Verify Everything Works

```bash
bash fedora_setup/verify_dev_environment.sh
```

Should show: ✓ PASSED: 30/30 checks ✅

### 2. Configure Git (5 minutes)

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify
git config --global --list | grep user
```

### 3. Add SSH Key to GitHub (5 minutes)

```bash
# Display your SSH public key
cat ~/.ssh/id_ed25519.pub
```

Copy the output, then:
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Paste the key
4. Save

Test connection:
```bash
ssh -T git@github.com
# Should output: "Hi YourUsername! You've successfully authenticated..."
```

---

## 🚀 Quick Test (10 minutes)

### Test Node.js + Web Development

```bash
# Create a React app
pnpm create vite test-app --template react

# Install and run
cd test-app
pnpm install
pnpm dev

# Visit http://localhost:5173 in your browser
# Ctrl+C to stop
```

### Test Python

```bash
# Create an environment
conda create -n test-py python=3.11
conda activate test-py

# Install a library
pip install requests

# Test
python -c "import requests; print(requests.__version__)"

# Deactivate
conda deactivate
```

### Test Containers

```bash
# Run a simple container
podman run --rm hello-world

# Run PostgreSQL in a container
podman run -d \
  -e POSTGRES_PASSWORD=dev \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  --name postgres-dev \
  postgres:15

# Test connection
psql -U postgres -h localhost -d postgres -c "SELECT 1"

# Stop container
podman stop postgres-dev
podman rm postgres-dev
```

---

## 📚 Recommended Learning Path

### Beginner (Week 1-2)

**JavaScript/Web:**
- [ ] [FreeCodeCamp - Responsive Web Design](https://www.freecodecamp.org/)
- [ ] [MDN Web Docs](https://developer.mozilla.org/)
- [ ] [React Tutorial](https://react.dev/learn)

**Or Python:**
- [ ] [Python.org Getting Started](https://www.python.org/about/gettingstarted/)
- [ ] [Real Python - Python Basics](https://realpython.com/)
- [ ] [Codecademy - Python for Beginners](https://www.codecademy.com/)

**Or Containers:**
- [ ] [Docker/Podman Getting Started](https://docs.podman.io/en/latest/)
- [ ] [Play with Docker](https://labs.play-with-docker.com/)

### Intermediate (Week 3-4)

**JavaScript:**
- [ ] Build a small project (todo app, calculator, weather app)
- [ ] Learn Git flow (branches, commits, PRs)
- [ ] Deploy to a free platform (Vercel, Netlify)

**Python:**
- [ ] Build a CLI tool or web scraper
- [ ] Learn virtual environments and requirements.txt
- [ ] Try a framework (Flask, Django)

**DevOps:**
- [ ] Learn Docker/Podman basics
- [ ] Build a multi-container app
- [ ] Learn about networking and volumes

---

## 🛠️ Project Ideas by Skill Level

### Beginner (Your First Project)

**JavaScript:**
- Interactive todo list
- Weather app (using free API)
- Calculator with UI
- Markdown note app

**Python:**
- CLI todo tracker
- Web scraper (BeautifulSoup)
- Password manager
- Unit converter

**Full-Stack:**
- Simple blog (Node + Postgres)
- Task tracker (React + Node + Postgres)

### Intermediate

**JavaScript:**
- Social media clone (Twitter/Instagram)
- Chat application (Socket.io)
- E-commerce site

**Python:**
- Data analysis project (pandas, matplotlib)
- API with Flask/FastAPI
- Discord bot

**DevOps:**
- Multi-container Docker Compose setup
- CI/CD pipeline (GitHub Actions)
- Kubernetes practice (k3d optional)

---

## 💾 Database Setup

### PostgreSQL (Local)

```bash
# Connect with psql
psql -U $USER -d $USER

# Create a new database
createdb my_project

# Connect to it
psql -d my_project

# Useful commands
\l      # List databases
\dt     # List tables
\du     # List users
\q      # Quit
```

### Redis (Local)

```bash
# Start Redis server
redis-server

# In another terminal, test
redis-cli ping
redis-cli set mykey "Hello"
redis-cli get mykey
```

### PostgreSQL in Container

```bash
# Run Postgres
podman run -d \
  --name my-postgres \
  -e POSTGRES_USER=dev \
  -e POSTGRES_PASSWORD=dev123 \
  -p 5432:5432 \
  postgres:15

# Connect
psql -U dev -h localhost

# Stop
podman stop my-postgres
```

---

## 📦 Node.js Tips

### Using pnpm

```bash
# Create a new project
pnpm create vite my-app

# Install dependencies
pnpm install

# Add a package
pnpm add express

# Add dev dependency
pnpm add -D eslint

# Update packages
pnpm up

# Run scripts
pnpm dev
pnpm build
```

### Useful npm/pnpm packages

```bash
# Web framework
pnpm add express fastify

# Database ORM
pnpm add sequelize typeorm

# Testing
pnpm add -D jest vitest

# API testing
pnpm add axios fetch

# Utilities
pnpm add lodash moment axios
```

---

## 🐍 Python Tips

### Using Conda

```bash
# Create environment
conda create -n myenv python=3.11

# Activate
conda activate myenv

# Install packages
conda install pandas numpy requests

# Or with pip
pip install flask django fastapi

# Deactivate
conda deactivate

# List environments
conda env list

# Remove environment
conda env remove -n myenv
```

### Useful Python packages

```bash
# Web frameworks
pip install flask django fastapi

# Data science
pip install pandas numpy scikit-learn matplotlib

# Database
pip install sqlalchemy psycopg2 pymongo

# Testing
pip install pytest

# API clients
pip install requests httpx
```

---

## 🐳 Container Tips

### Docker/Podman Commands

```bash
# Run a container
podman run -d -p 8080:80 nginx

# List running containers
podman ps

# View logs
podman logs container-name

# Stop container
podman stop container-name

# Execute command in container
podman exec -it container-name bash

# Remove container
podman rm container-name

# Build image from Dockerfile
podman build -t myimage .
```

### Docker Compose (Pod Container)

Create `docker-compose.yml`:
```yaml
version: '3'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: dev
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

Run:
```bash
podman-compose up -d
podman-compose down
```

---

## 🔑 Git Workflow

### Clone and contribute to a project

```bash
# Clone repo
git clone https://github.com/user/project.git
cd project

# Create a branch
git checkout -b feature/my-feature

# Make changes
# ...

# Stage and commit
git add .
git commit -m "Add my feature"

# Push
git push origin feature/my-feature

# Create a Pull Request on GitHub
```

### Useful git commands

```bash
git status           # Check status
git log --oneline    # View commits
git diff             # See changes
git checkout <file>  # Discard changes
git branch -a        # List branches
git stash            # Temporarily save changes
```

---

## 🎯 Next Goals (Month 1)

- [ ] Complete Git basics tutorial
- [ ] Build your first project
- [ ] Deploy something (Vercel, Heroku, etc.)
- [ ] Contribute to open source
- [ ] Join developer communities

---

## 🌐 Communities & Resources

### JavaScript/Web
- [Dev.to](https://dev.to/)
- [FreeCodeCamp](https://www.freecodecamp.org/)
- [Stack Overflow - JavaScript](https://stackoverflow.com/questions/tagged/javascript)

### Python
- [Real Python](https://realpython.com/)
- [PyCharm Blog](https://blog.jetbrains.com/pycharm/)
- [Python Subreddit](https://www.reddit.com/r/learnprogramming/)

### DevOps/Containers
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### General
- [GitHub Discussions](https://github.com/discussions)
- [Hacker News](https://news.ycombinator.com/)
- [Lobsters](https://lobste.rs/)

---

## 📞 Need Help?

- **Bug in setup?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Questions?** [GitHub Discussions](https://github.com/yourusername/fedora-dev-setup/discussions)
- **Want to contribute?** See [CONTRIBUTING.md](../CONTRIBUTING.md)

---

**Happy coding!** 🚀

Next milestone: Build and deploy your first project!
