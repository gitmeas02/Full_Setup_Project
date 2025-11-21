# 🚀 Deployment & Testing Guide

## ✅ Pre-Deployment Checklist

Run this verification script to check your setup:

### Windows
```cmd
check-setup.bat
```

### Linux/Mac
```bash
chmod +x check-setup.sh
./check-setup.sh
```

---

## 📋 Quick Deployment Options

### Option 1: Local Development (Fastest)
```bash
# From project root
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f app
```

**Access Points:**
- Application: http://localhost:8080
- Actuator Health: http://localhost:8080/actuator/health
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin123)

---

### Option 2: Build & Run Application Only
```bash
# Navigate to email folder
cd email

# Build application
./gradlew clean build         # Linux/Mac
gradlew.bat clean build        # Windows

# Run JAR
java -jar build/libs/*.jar

# Or build Docker image
docker build -t email-service:latest .
docker run -p 8080:8080 email-service:latest
```

---

### Option 3: Full CI/CD with Jenkins (Dockerized)

#### 1️⃣ Setup Jenkins with Docker (Recommended)
```bash
# Option A: Full DevOps Stack (Jenkins + SonarQube + App + Monitoring)
docker-compose -f docker-compose.full.yml up -d

# Option B: Jenkins Only
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts-jdk21

# Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**See `jenkins/DOCKER-SETUP.md` for complete Docker setup guide**

#### 2️⃣ Configure Jenkins (Docker)
1. Open http://localhost:8081
2. Enter initial password (from command above)
3. Install suggested plugins (or skip - already pre-installed in custom image)

4. Add Credentials (Manage Jenkins → Credentials):
   - **docker-hub-credentials**: Docker Hub username/password
   - **ansible-ssh-key**: SSH private key

5. Configure SonarQube (if using full stack):
   - Manage Jenkins → Configure System
   - SonarQube Server URL: `http://sonarqube:9000`
   - Generate token from SonarQube UI

#### 3️⃣ Create Pipeline Job
1. New Item → Pipeline
2. Name: `email-service-pipeline`
3. Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository: https://github.com/gitmeas02/Full_Setup_Project.git
   - Branch: */main
   - Script Path: `Jenkinsfile`

4. Save & Build Now

---

### Option 4: Deploy with Ansible

#### 1️⃣ Setup Target Servers
```bash
cd ansible

# Update inventory files with your server IPs
nano inventory/dev.ini

# Test connectivity
ansible all -i inventory/dev.ini -m ping

# Setup Docker on servers
ansible-playbook -i inventory/dev.ini setup.yml
```

#### 2️⃣ Deploy Application
```bash
# Deploy to Development
ansible-playbook -i inventory/dev.ini deploy.yml -e "docker_tag=latest"

# Deploy to Staging
ansible-playbook -i inventory/staging.ini deploy.yml -e "docker_tag=1.0.0"

# Deploy to Production
ansible-playbook -i inventory/prod.ini deploy.yml -e "docker_tag=1.0.0"
```

---

### Option 5: GitHub Actions (Automated)

#### 1️⃣ Add Secrets to GitHub
Go to: Repository → Settings → Secrets and variables → Actions

Add these secrets:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password
- `SSH_PRIVATE_KEY`: SSH key for deployment servers

#### 2️⃣ Trigger Workflow
- Push to `main` branch → Deploys to Production
- Push to `develop` branch → Deploys to Dev
- Create Pull Request → Runs tests only

---

## 🧪 Verification & Testing

### 1. Check Application Health
```bash
# Using curl
curl http://localhost:8080/actuator/health

# Expected response:
# {"status":"UP"}
```

### 2. Check Docker Containers
```bash
docker-compose ps

# All containers should be "Up" and "healthy"
```

### 3. Check Logs
```bash
# Application logs
docker-compose logs -f app

# All services
docker-compose logs -f

# Specific service
docker logs email-app
```

### 4. Test Database Connection
```bash
# Access PostgreSQL
docker exec -it email-postgres psql -U emailuser -d emaildb

# List databases
\l

# Exit
\q
```

### 5. Test Redis
```bash
# Access Redis CLI
docker exec -it email-redis redis-cli

# Test commands
PING
# Should return: PONG

SET test "Hello"
GET test
# Should return: "Hello"

exit
```

### 6. Check Prometheus Metrics
```bash
# Open browser
http://localhost:9090/targets

# All targets should be "UP"
```

### 7. Check Grafana Dashboard
```bash
# Login to Grafana
http://localhost:3000
# Username: admin
# Password: admin123

# Add Prometheus data source:
# URL: http://prometheus:9090
```

---

## 🔍 Troubleshooting

### Application Won't Start
```bash
# Check logs
docker-compose logs app

# Common issues:
# 1. Port 8080 already in use
sudo lsof -i :8080  # Find process
kill -9 <PID>       # Kill process

# 2. Database not ready
docker-compose restart postgres
docker-compose restart app
```

### Docker Build Fails
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
cd email
docker build --no-cache -t email-service:latest .
```

### Ansible Connection Failed
```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa ubuntu@<server-ip>

# Check inventory file
cat ansible/inventory/dev.ini

# Update SSH key path
nano ansible/inventory/dev.ini
```

### Jenkins Build Fails
```bash
# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Verify Docker permissions
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Verify Gradle/JDK installed
./gradlew --version
java --version
```

---

## 📊 Performance Testing

### Load Test with curl
```bash
# Simple load test
for i in {1..100}; do
  curl http://localhost:8080/actuator/health &
done
wait
```

### Load Test with Apache Bench
```bash
# Install ab
sudo apt install apache2-utils

# Run test (100 requests, 10 concurrent)
ab -n 100 -c 10 http://localhost:8080/actuator/health
```

---

## 🔄 Common Operations

### Restart Services
```bash
# Restart all
docker-compose restart

# Restart app only
docker-compose restart app

# Stop all
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### View Resource Usage
```bash
# Docker stats
docker stats

# Container-specific
docker stats email-app
```

### Update Application
```bash
# 1. Pull latest code
git pull origin main

# 2. Rebuild
docker-compose build app

# 3. Restart
docker-compose up -d app

# Or with Ansible
cd ansible
ansible-playbook -i inventory/dev.ini deploy.yml -e "docker_tag=new-version"
```

### Rollback Deployment
```bash
# Using Ansible
ansible-playbook -i inventory/prod.ini deploy.yml -e "docker_tag=previous-version"

# Using docker-compose
docker-compose down
git checkout <previous-commit>
docker-compose up -d
```

---

## 🎯 Success Criteria

Your setup is correct when:

- ✅ `docker-compose ps` shows all containers as "Up" and "healthy"
- ✅ http://localhost:8080/actuator/health returns `{"status":"UP"}`
- ✅ http://localhost:9090/targets shows all targets as "UP"
- ✅ http://localhost:3000 loads Grafana dashboard
- ✅ No errors in `docker-compose logs`
- ✅ Jenkins pipeline runs successfully
- ✅ Ansible playbook completes without errors

---

## 📞 Support

If issues persist:
1. Run `check-setup.sh` or `check-setup.bat`
2. Check logs: `docker-compose logs -f`
3. Verify prerequisites are installed
4. Check firewall/port availability

**Repository:** https://github.com/gitmeas02/Full_Setup_Project
