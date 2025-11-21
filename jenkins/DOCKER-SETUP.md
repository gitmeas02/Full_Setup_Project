# 🐳 Dockerized Jenkins Setup

## Why Docker for Jenkins?

✅ **Advantages:**
- No manual installation on server
- Consistent environment across all machines
- Easy to upgrade (just pull new image)
- Isolated from host system
- Can be version controlled
- Easy backup and restore (just volume)
- Includes all tools (Docker, Ansible, Gradle)

❌ **Server Installation Drawbacks:**
- Manual setup on each server
- Dependency conflicts
- Hard to replicate
- Manual updates
- System pollution

---

## 🚀 Quick Start - Dockerized Jenkins

### Option 1: Jenkins Only
```bash
# Start Jenkins with Docker access
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts-jdk21
```

### Option 2: Full DevOps Stack (Recommended)
```bash
# Start everything: Jenkins, SonarQube, App, Monitoring
docker-compose -f docker-compose.full.yml up -d
```

**This includes:**
- Jenkins (http://localhost:8081)
- SonarQube (http://localhost:9000)
- Application (http://localhost:8080)
- Prometheus (http://localhost:9090)
- Grafana (http://localhost:3000)
- PostgreSQL + Redis

---

## 📦 What's Included in Dockerized Jenkins

### Pre-installed Plugins:
- ✅ Docker Pipeline
- ✅ Ansible Plugin
- ✅ Git
- ✅ SonarQube Scanner
- ✅ JUnit & Jacoco
- ✅ Email Extension
- ✅ Blue Ocean (Modern UI)

### Pre-installed Tools:
- ✅ Docker CLI
- ✅ Docker Compose
- ✅ Ansible
- ✅ Trivy (Security Scanner)
- ✅ JDK 21
- ✅ Python 3

---

## 🔧 Setup Instructions

### Step 1: Start Jenkins Container

#### Using docker-compose.full.yml (All-in-One):
```bash
# Start full stack
docker-compose -f docker-compose.full.yml up -d

# Check status
docker-compose -f docker-compose.full.yml ps

# View Jenkins logs
docker-compose -f docker-compose.full.yml logs -f jenkins
```

#### Using Custom Dockerfile:
```bash
# Build custom Jenkins image
cd jenkins
docker build -t jenkins-custom:latest .

# Run container
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/../email:/workspace/email:ro \
  --network devops-network \
  jenkins-custom:latest
```

### Step 2: Access Jenkins

1. Open browser: http://localhost:8081

2. Get initial admin password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

3. Complete setup wizard or skip (already pre-configured)

### Step 3: Configure Jenkins

#### Add Docker Hub Credentials:
1. Manage Jenkins → Credentials
2. Add Credentials → Username with password
3. ID: `docker-hub-credentials`
4. Username: Your Docker Hub username
5. Password: Your Docker Hub token

#### Add SSH Key for Ansible:
1. Manage Jenkins → Credentials
2. Add Credentials → SSH Username with private key
3. ID: `ansible-ssh-key`
4. Username: ubuntu (or your server user)
5. Private Key: Paste your SSH private key

#### Configure SonarQube:
1. Manage Jenkins → Configure System
2. SonarQube servers:
   - Name: `SonarQube`
   - Server URL: `http://sonarqube:9000`
   - Server token: (generate from SonarQube)

### Step 4: Create Pipeline

1. New Item → Pipeline
2. Name: `email-service-pipeline`
3. Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository: https://github.com/gitmeas02/Full_Setup_Project.git
   - Branch: */main
   - Script Path: `Jenkinsfile`
4. Save

### Step 5: Run Pipeline

Click "Build Now" - Jenkins will:
1. ✅ Checkout code from Git
2. ✅ Build with Gradle
3. ✅ Run tests
4. ✅ Analyze with SonarQube
5. ✅ Build Docker image
6. ✅ Scan with Trivy
7. ✅ Push to Docker Hub
8. ✅ Deploy with Ansible

---

## 🔍 Jenkins Container Features

### Docker-in-Docker (DinD)
Jenkins can build and run Docker images by mounting the host's Docker socket:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Workspace Mounting
Access your code without cloning:
```yaml
volumes:
  - ./email:/workspace/email:ro
```

### Persistent Data
All Jenkins data saved in named volume:
```yaml
volumes:
  - jenkins_home:/var/jenkins_home
```

---

## 🎯 Comparison: Docker vs Server Installation

| Feature | Dockerized Jenkins | Server Installation |
|---------|-------------------|---------------------|
| **Setup Time** | 2 minutes | 30+ minutes |
| **Installation** | `docker-compose up` | Manual apt/yum install |
| **Updates** | Pull new image | Manual upgrade |
| **Consistency** | Same everywhere | Varies by server |
| **Isolation** | Containerized | System-wide |
| **Backup** | Volume backup | Full system backup |
| **Tools** | Pre-installed | Manual install each |
| **Portability** | Any Docker host | Tied to server |
| **Clean Removal** | `docker-compose down` | Manual uninstall |

**Winner: 🐳 Dockerized Jenkins**

---

## 📊 Architecture

```
┌─────────────────────────────────────────┐
│         Docker Host (Your PC)           │
│                                         │
│  ┌────────────────────────────────┐   │
│  │  Jenkins Container (8081)      │   │
│  │  - Has Docker CLI              │   │
│  │  - Can build images            │   │
│  │  - Can run Ansible             │   │
│  │  - Runs pipelines              │   │
│  └────────────────────────────────┘   │
│           │                            │
│           │ Docker Socket              │
│           ↓                            │
│  ┌────────────────────────────────┐   │
│  │  Docker Engine (Host)          │   │
│  │  - Builds images               │   │
│  │  - Runs containers             │   │
│  └────────────────────────────────┘   │
│                                         │
│  ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │   App    │ │SonarQube │ │  DB    │ │
│  │  :8080   │ │  :9000   │ │ :5432  │ │
│  └──────────┘ └──────────┘ └────────┘ │
└─────────────────────────────────────────┘
```

---

## 🛠️ Common Operations

### View Jenkins Logs
```bash
docker logs -f jenkins
# or
docker-compose -f docker-compose.full.yml logs -f jenkins
```

### Restart Jenkins
```bash
docker restart jenkins
# or
docker-compose -f docker-compose.full.yml restart jenkins
```

### Backup Jenkins
```bash
# Backup Jenkins home
docker run --rm \
  -v jenkins_home:/source:ro \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/jenkins_backup_$(date +%Y%m%d).tar.gz -C /source .
```

### Restore Jenkins
```bash
# Restore from backup
docker run --rm \
  -v jenkins_home:/target \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/jenkins_backup_YYYYMMDD.tar.gz -C /target
```

### Update Jenkins
```bash
# Pull latest image
docker pull jenkins/jenkins:lts-jdk21

# Recreate container
docker-compose -f docker-compose.full.yml up -d --force-recreate jenkins
```

### Access Jenkins Shell
```bash
docker exec -it jenkins bash
```

---

## 🔐 Security Considerations

### Docker Socket Access
Mounting `/var/run/docker.sock` gives Jenkins full Docker control. This is necessary but powerful.

**Mitigation:**
- Run Jenkins in isolated network
- Use credentials for sensitive operations
- Regularly update Jenkins image
- Scan images with Trivy

### Credentials Management
- Never commit credentials to Git
- Use Jenkins credentials store
- Rotate secrets regularly
- Use environment variables

---

## 🚀 Production Recommendations

### For Production:
```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts-jdk21
    restart: always
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/login"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Use External Storage
```yaml
volumes:
  - /mnt/jenkins_data:/var/jenkins_home  # External disk
```

---

## 📝 Files Created

- ✅ `docker-compose.full.yml` - Complete stack with Jenkins
- ✅ `jenkins/Dockerfile` - Custom Jenkins image
- ✅ `jenkins/DOCKER-SETUP.md` - This guide

---

## ✅ Advantages Summary

**Why Dockerized Jenkins is Better:**

1. ✅ **Zero manual installation** - Just `docker-compose up`
2. ✅ **Pre-configured** - Plugins already installed
3. ✅ **Reproducible** - Same setup everywhere
4. ✅ **Easy updates** - Pull new image
5. ✅ **Portable** - Run on any Docker host
6. ✅ **Isolated** - No system conflicts
7. ✅ **Backup friendly** - Just volume backup
8. ✅ **Version controlled** - Dockerfile in Git

---

## 🎯 Quick Commands

```bash
# Start full DevOps stack
docker-compose -f docker-compose.full.yml up -d

# Get Jenkins password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins
open http://localhost:8081

# Check all services
docker-compose -f docker-compose.full.yml ps

# View all logs
docker-compose -f docker-compose.full.yml logs -f

# Stop everything
docker-compose -f docker-compose.full.yml down
```

---

**Recommendation: Always use Dockerized Jenkins! 🐳**
