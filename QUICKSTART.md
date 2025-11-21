# Quick Start Guide 🚀

## Run Setup Verification First!

**Windows:**
```cmd
check-setup.bat
```

**Linux/Mac:**
```bash
chmod +x check-setup.sh
./check-setup.sh
```

---

## Option 1: Local Development (Recommended for Testing)

### Start Everything
```bash
# From project root
docker-compose up -d
```

### Check Status
```bash
docker-compose ps
```

### Test the Application
```bash
# Health check
curl http://localhost:8080/actuator/health

# Should return: {"status":"UP"}
```

### Access Services
- **Application**: http://localhost:8080/actuator/health
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin123)

### View Logs
```bash
docker-compose logs -f app
```

### Stop Everything
```bash
docker-compose down
```

---

## Option 2: Build Application Only

### Windows
```cmd
cd email
gradlew.bat clean build
java -jar build\libs\email-0.0.1-SNAPSHOT.jar
```

### Linux/Mac
```bash
cd email
./gradlew clean build
java -jar build/libs/email-0.0.1-SNAPSHOT.jar
```

---

## Option 3: Docker Only (App Container)

```bash
cd email
docker build -t email-service:latest .
docker run -p 8080:8080 email-service:latest
```

---

## ✅ Verify Setup is Correct

### 1. All Containers Running?
```bash
docker-compose ps

# Expected: All show "Up" and "healthy"
```

### 2. Application Healthy?
```bash
curl http://localhost:8080/actuator/health

# Expected: {"status":"UP"}
```

### 3. Database Working?
```bash
docker exec -it email-postgres psql -U emailuser -d emaildb -c "\l"

# Expected: List of databases
```

### 4. Redis Working?
```bash
docker exec -it email-redis redis-cli ping

# Expected: PONG
```

### 5. No Errors in Logs?
```bash
docker-compose logs app | grep -i error

# Expected: No critical errors
```

---

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8080
kill -9 <PID>
```

### Docker Build Fails
```bash
# Clean everything
docker-compose down -v
docker system prune -a

# Rebuild
docker-compose build --no-cache
docker-compose up -d
```

### Application Won't Start
```bash
# Check Java version
java -version
# Should be Java 21

# Check logs
docker-compose logs app
```

---

## 📚 Full Documentation

See **DEPLOYMENT.md** for:
- Jenkins CI/CD setup
- Ansible deployment
- GitHub Actions
- Production deployment
- Advanced troubleshooting

---

## 🎯 Success Checklist

- ✅ `check-setup.bat` or `check-setup.sh` passes
- ✅ `docker-compose ps` shows all containers "Up"
- ✅ `curl http://localhost:8080/actuator/health` returns UP
- ✅ Prometheus accessible at http://localhost:9090
- ✅ Grafana accessible at http://localhost:3000
- ✅ No errors in `docker-compose logs`

**If all above pass, your setup is 100% correct! 🎉**
