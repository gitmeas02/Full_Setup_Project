# Complete DevOps Stack

Complete CI/CD automation with **Jenkins**, **Ansible**, and **Docker** for Spring Boot microservices.

## 📁 Project Structure

```
Spring_Full_set_up/
├── email/                      # Spring Boot application
│   ├── src/
│   ├── build.gradle
│   ├── Dockerfile             # App containerization
│   └── docker-compose.prod.yml
│
├── ansible/                    # Configuration Management
│   ├── ansible.cfg
│   ├── deploy.yml             # Deployment playbook
│   ├── setup.yml              # Infrastructure setup
│   ├── inventory/
│   │   ├── dev.ini
│   │   ├── staging.ini
│   │   └── prod.ini
│   └── templates/
│       └── app.env.j2
│
├── jenkins/                    # CI/CD (placeholder for configs)
│
├── monitoring/                 # Observability
│   └── prometheus.yml
│
├── Jenkinsfile                # CI/CD Pipeline
└── docker-compose.yml         # Full stack orchestration
```

## 🎯 File Organization

### Infrastructure Files (Root Level)
- **Jenkinsfile** - CI/CD pipeline definition
- **docker-compose.yml** - Full stack with services
- **ansible/** - Deployment automation
- **monitoring/** - Prometheus config

### Application Files (email/)
- **Dockerfile** - App containerization
- **docker-compose.prod.yml** - Production config
- **src/** - Source code

## 🚀 Quick Start

### 1. Local Development
```bash
# Start all services (from root)
docker-compose up -d

# Access
# App: http://localhost:8080
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000
```

### 2. Setup Infrastructure
```bash
cd ansible
ansible-playbook -i inventory/dev.ini setup.yml
```

### 3. Deploy Application
```bash
# Deploy to Dev
ansible-playbook -i inventory/dev.ini deploy.yml -e "docker_tag=latest"

# Deploy to Production
ansible-playbook -i inventory/prod.ini deploy.yml -e "docker_tag=1.0.0"
```

## 🔧 Jenkins Setup

### Prerequisites
Install plugins:
- Docker Pipeline
- Ansible Plugin
- SonarQube Scanner
- JUnit Plugin
- Jacoco Plugin

### Configure Credentials
- `docker-hub-credentials` - Docker registry
- `ansible-ssh-key` - Server SSH access

### Create Pipeline Job
1. New Item → Pipeline
2. SCM: Git (your repo URL)
3. Script Path: `Jenkinsfile`

## 📦 Deployment Pipeline

```
Checkout → Build → Test → Quality → Docker → Security → Push
   ↓
Deploy Dev → Integration Tests → Deploy Staging → Approve → Production
```

## 🐳 Docker Commands

```bash
# Build app image
cd email
docker build -t email-service:latest .

# Run locally
docker run -p 8080:8080 email-service:latest

# Full stack
docker-compose up -d
```

## 📊 Monitoring

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin123)
- **App Metrics**: http://localhost:8080/actuator/prometheus

## 🔐 Configuration

Update `ansible/inventory/*.ini` with:
- Server IPs
- SSH keys
- Database credentials
- Docker registry details

## 🛠️ Useful Commands

```bash
# Ansible
ansible-playbook -i inventory/dev.ini deploy.yml --check  # Dry run
ansible all -i inventory/dev.ini -m ping                  # Test connectivity

# Docker
docker-compose logs -f app                                # View logs
docker-compose down -v                                    # Stop and remove

# Jenkins
# Trigger from Git hook or manually
```

## 📝 Environment Variables

Required for deployment:
- `DOCKER_REGISTRY` - Registry URL
- `DOCKER_USERNAME` - Registry user
- `DB_HOST` - Database host
- `DB_NAME` - Database name

## 🔄 Rollback

```bash
ansible-playbook -i inventory/prod.ini deploy.yml -e "docker_tag=previous-version"
```

## 📚 Documentation

- Jenkins: See `Jenkinsfile` for pipeline stages
- Ansible: Check `ansible/deploy.yml` for tasks
- Docker: Review `email/Dockerfile` for build

---

**Note**: Update all placeholders (IPs, credentials) before production use.
"# Full_Setup_Project" 
