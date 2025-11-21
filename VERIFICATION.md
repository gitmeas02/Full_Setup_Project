# ✅ DevOps Stack - Complete Setup Verification

## 📋 How to Deploy and Verify Setup

### Step 1: Run Setup Verification ✓

**Windows:**
```cmd
check-setup.bat
```

**Linux/Mac:**
```bash
chmod +x check-setup.sh
./check-setup.sh
```

**What it checks:**
- ✅ Docker & Docker Compose installed
- ✅ Java 21 installed
- ✅ Git installed
- ✅ All project files present (Jenkinsfile, docker-compose.yml, etc.)
- ✅ Gradle wrapper exists and executable
- ✅ Required ports available (8080, 5432, 6379, 9090, 3000)
- ✅ Docker daemon running
- ✅ Git repository configured

---

### Step 2: Deploy Locally 🚀

```bash
# Start all services
docker-compose up -d

# Wait 30 seconds for services to start
# Then verify:
curl http://localhost:8080/actuator/health
```

**Expected Response:**
```json
{"status":"UP"}
```

---

### Step 3: Verify All Services ✓

#### Check Container Status
```bash
docker-compose ps
```

**Expected Output:**
```
NAME                STATUS              PORTS
email-app           Up (healthy)        0.0.0.0:8080->8080/tcp
email-postgres      Up (healthy)        0.0.0.0:5432->5432/tcp
email-redis         Up (healthy)        0.0.0.0:6379->6379/tcp
email-prometheus    Up                  0.0.0.0:9090->9090/tcp
email-grafana       Up                  0.0.0.0:3000->3000/tcp
```

#### Test Each Service

**1. Application Health**
```bash
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}
```

**2. Application Info**
```bash
curl http://localhost:8080/actuator/info
# Expected: Application metadata
```

**3. Prometheus Metrics**
```bash
curl http://localhost:8080/actuator/prometheus
# Expected: Metrics in Prometheus format
```

**4. Database Connection**
```bash
docker exec -it email-postgres psql -U emailuser -d emaildb -c "SELECT version();"
# Expected: PostgreSQL version info
```

**5. Redis Connection**
```bash
docker exec -it email-redis redis-cli ping
# Expected: PONG
```

**6. Prometheus**
Open browser: http://localhost:9090/targets
- **Expected:** All targets show "UP"

**7. Grafana**
Open browser: http://localhost:3000
- Login: admin / admin123
- **Expected:** Dashboard loads successfully

---

### Step 4: Check Logs for Errors 🔍

```bash
# View all logs
docker-compose logs

# View app logs only
docker-compose logs app

# Follow logs in real-time
docker-compose logs -f app

# Check for errors
docker-compose logs app | grep -i error
docker-compose logs app | grep -i exception
```

**Expected:** No critical errors or stack traces

---

## ✅ Setup is Correct When:

### Required Checks (Must Pass)
- [x] `check-setup.bat/sh` completes with 0 errors
- [x] `docker-compose ps` shows all containers as "Up"
- [x] `curl http://localhost:8080/actuator/health` returns `{"status":"UP"}`
- [x] Prometheus shows all targets as "UP" at http://localhost:9090/targets
- [x] Grafana loads at http://localhost:3000
- [x] `docker-compose logs app` shows no critical errors

### Database Verification
- [x] PostgreSQL container is healthy
- [x] Can connect: `docker exec -it email-postgres psql -U emailuser -d emaildb`
- [x] Database `emaildb` exists

### Redis Verification
- [x] Redis container is healthy
- [x] `docker exec -it email-redis redis-cli ping` returns "PONG"

### Docker Verification
- [x] Docker build succeeds: `cd email && docker build -t email-service:test .`
- [x] No dangling images or orphaned containers
- [x] Volumes are created (postgres_data, prometheus_data, grafana_data)

---

## 🔧 Troubleshooting Common Issues

### Issue 1: Port Already in Use
**Symptom:** "Error: address already in use"

**Fix:**
```bash
# Find process using port
netstat -ano | findstr :8080     # Windows
lsof -i :8080                    # Linux/Mac

# Kill the process or change port in docker-compose.yml
```

### Issue 2: Docker Build Fails
**Symptom:** "Error building image"

**Fix:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
cd email
docker build --no-cache -t email-service:latest .
```

### Issue 3: Application Won't Start
**Symptom:** Container exits immediately

**Fix:**
```bash
# Check Java version in container
docker run --rm eclipse-temurin:21-jre-alpine java -version

# Check application logs
docker-compose logs app

# Verify JAR file was built
docker run --rm -v $(pwd)/email:/app gradle:8.5-jdk21-alpine /bin/sh -c "cd /app && ./gradlew build"
```

### Issue 4: Database Connection Failed
**Symptom:** "Connection refused" or "Unknown database"

**Fix:**
```bash
# Restart PostgreSQL
docker-compose restart postgres

# Check database is ready
docker-compose logs postgres | grep "database system is ready"

# Verify connection string
docker exec -it email-app env | grep SPRING_DATASOURCE
```

### Issue 5: Gradle Permission Denied
**Symptom:** "Permission denied: ./gradlew"

**Fix:**
```bash
chmod +x email/gradlew
```

---

## 📊 Performance Verification

### Load Test
```bash
# Simple load test (100 requests)
for i in {1..100}; do curl -s http://localhost:8080/actuator/health > /dev/null & done
wait

# Check response time
time curl http://localhost:8080/actuator/health
```

**Expected:** Response time < 500ms

### Resource Usage
```bash
# Check container resource usage
docker stats --no-stream

# Expected for app container:
# CPU: < 50%
# Memory: < 512MB
```

---

## 🎯 Production Readiness Checklist

Before deploying to production:

### Security
- [ ] Update default passwords in `docker-compose.yml`
- [ ] Use environment variables for secrets
- [ ] Enable HTTPS/TLS
- [ ] Update Grafana admin password
- [ ] Configure firewall rules

### Configuration
- [ ] Update `ansible/inventory/prod.ini` with real server IPs
- [ ] Add SSH keys for Ansible deployment
- [ ] Configure Docker Hub credentials in Jenkins
- [ ] Set up SonarQube server
- [ ] Configure email notifications

### Monitoring
- [ ] Set up Grafana dashboards
- [ ] Configure Prometheus alerts
- [ ] Set up log aggregation
- [ ] Configure backup strategy

### CI/CD
- [ ] Jenkins installed and configured
- [ ] Pipeline tested end-to-end
- [ ] Ansible playbooks tested on staging
- [ ] Rollback procedure tested

---

## 🎉 Success!

If all checks pass, your DevOps stack is **100% correctly set up**!

### What You Have Now:

✅ **Containerized Spring Boot Application**
- Multi-stage Docker build
- Health checks configured
- Running on port 8080

✅ **Database Stack**
- PostgreSQL with persistent storage
- Redis cache
- Connection pooling

✅ **Monitoring Stack**
- Prometheus metrics collection
- Grafana dashboards
- Application metrics exposed

✅ **CI/CD Infrastructure**
- Jenkins pipeline ready
- Ansible playbooks configured
- GitHub Actions workflow

✅ **Development Workflow**
- Local development with docker-compose
- Hot reload capability
- Log aggregation

---

## 📚 Next Steps

1. **Add Your Business Logic** - Develop your email service features
2. **Configure Jenkins** - Set up CI/CD pipeline (see `DEPLOYMENT.md`)
3. **Deploy to Staging** - Use Ansible playbooks
4. **Set Up Monitoring** - Configure Grafana dashboards
5. **Deploy to Production** - Follow production checklist

---

## 📞 Need Help?

- **Quick Reference:** See `QUICKSTART.md`
- **Full Deployment:** See `DEPLOYMENT.md`
- **Jenkins Setup:** See `jenkins/README.md`
- **Repository:** https://github.com/gitmeas02/Full_Setup_Project

---

**Remember:** Run `check-setup.bat` or `check-setup.sh` anytime to verify your setup!
