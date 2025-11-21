# Jenkins Configuration Guide

## Overview
This directory contains Jenkins-related configurations and scripts.

## Setup Instructions

### 1. Install Jenkins
```bash
# Ubuntu/Debian
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```

### 2. Required Plugins
Install from Jenkins UI (Manage Jenkins → Manage Plugins):
- Docker Pipeline
- Ansible Plugin
- SonarQube Scanner
- JUnit Plugin
- Jacoco Plugin
- Email Extension Plugin
- Git Plugin
- Pipeline Plugin

### 3. Configure Tools
Navigate to: Manage Jenkins → Global Tool Configuration

**Gradle:**
- Name: `Gradle-8.5`
- Version: Gradle 8.5

**JDK:**
- Name: `JDK-21`
- Install from: java.sun.com
- Version: JDK 21

**SonarQube:**
- Name: `SonarQube`
- Server URL: http://your-sonarqube-server:9000

### 4. Configure Credentials
Navigate to: Manage Jenkins → Manage Credentials

Add the following credentials:

**Docker Hub Credentials:**
- Kind: Username with password
- ID: `docker-hub-credentials`
- Username: Your Docker Hub username
- Password: Your Docker Hub password

**Ansible SSH Key:**
- Kind: SSH Username with private key
- ID: `ansible-ssh-key`
- Username: ubuntu (or your server user)
- Private Key: Your SSH private key

### 5. Create Pipeline Job

1. Click "New Item"
2. Enter name: "email-service-pipeline"
3. Select "Pipeline"
4. Click OK

**Pipeline Configuration:**
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: https://github.com/yourusername/your-repo.git
- Branch: */main
- Script Path: `Jenkinsfile`

### 6. Configure Webhooks (Optional)

**GitHub Webhook:**
1. Go to your GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: http://your-jenkins-server/github-webhook/
4. Content type: application/json
5. Events: Just the push event

### 7. Environment Variables

Set in Jenkins system configuration if needed:
- `DOCKER_REGISTRY`: docker.io
- `SONARQUBE_URL`: http://your-sonarqube:9000

## Pipeline Stages

1. **Checkout** - Clone repository
2. **Build** - Compile with Gradle
3. **Unit Tests** - Run tests with JUnit
4. **Code Quality** - SonarQube analysis
5. **Quality Gate** - Verify quality standards
6. **Build Docker Image** - Create container
7. **Security Scan** - Trivy vulnerability scan
8. **Push to Registry** - Upload to Docker Hub
9. **Deploy to Dev** - Deploy via Ansible
10. **Integration Tests** - E2E testing
11. **Deploy to Staging** - Staging deployment
12. **Approval** - Manual gate
13. **Deploy to Production** - Production deployment

## Troubleshooting

### Docker Permission Issues
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Ansible Connection Issues
Ensure SSH keys are properly configured and the Jenkins user can access them.

### SonarQube Integration
Verify SonarQube server is running and accessible from Jenkins.

## Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Pipeline Plugin](https://plugins.jenkins.io/docker-workflow/)
