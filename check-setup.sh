#!/bin/bash

# DevOps Stack Setup Verification Script
# This script checks if all required tools and configurations are present

echo "========================================="
echo "🔍 DevOps Stack Setup Verification"
echo "========================================="
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check command exists
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        if [ ! -z "$2" ]; then
            VERSION=$($1 $2 2>&1 | head -n 1)
            echo "  Version: $VERSION"
        fi
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        ((ERRORS++))
        return 1
    fi
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 NOT found"
        ((ERRORS++))
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 NOT found"
        ((ERRORS++))
        return 1
    fi
}

# Function to check port availability
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC} Port $1 is already in use"
        lsof -Pi :$1 -sTCP:LISTEN
        ((WARNINGS++))
        return 1
    else
        echo -e "${GREEN}✓${NC} Port $1 is available"
        return 0
    fi
}

echo "1️⃣  Checking Required Tools"
echo "-----------------------------------"
check_command "docker" "--version"
check_command "docker-compose" "--version"
check_command "java" "-version"
check_command "git" "--version"
echo ""

echo "2️⃣  Checking Optional Tools"
echo "-----------------------------------"
check_command "ansible" "--version" || echo -e "${YELLOW}   (Optional for deployment)${NC}"
check_command "curl" "--version" || echo -e "${YELLOW}   (Recommended for testing)${NC}"
echo ""

echo "3️⃣  Checking Project Structure"
echo "-----------------------------------"
check_file "Jenkinsfile"
check_file "docker-compose.yml"
check_file "README.md"
check_dir "email"
check_dir "ansible"
check_dir "monitoring"
check_file "email/Dockerfile"
check_file "email/build.gradle"
check_file "ansible/deploy.yml"
check_file "ansible/setup.yml"
check_dir "ansible/inventory"
check_file "ansible/inventory/dev.ini"
check_file "ansible/inventory/staging.ini"
check_file "ansible/inventory/prod.ini"
echo ""

echo "4️⃣  Checking Gradle Wrapper"
echo "-----------------------------------"
if [ -f "email/gradlew" ]; then
    echo -e "${GREEN}✓${NC} Gradle wrapper exists"
    if [ -x "email/gradlew" ]; then
        echo -e "${GREEN}✓${NC} Gradle wrapper is executable"
    else
        echo -e "${YELLOW}⚠${NC} Making gradlew executable..."
        chmod +x email/gradlew
    fi
else
    echo -e "${RED}✗${NC} Gradle wrapper NOT found"
    ((ERRORS++))
fi
echo ""

echo "5️⃣  Checking Port Availability"
echo "-----------------------------------"
check_port 8080  # Application
check_port 5432  # PostgreSQL
check_port 6379  # Redis
check_port 9090  # Prometheus
check_port 3000  # Grafana
echo ""

echo "6️⃣  Checking Docker Status"
echo "-----------------------------------"
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
    
    # Check if any containers are running
    RUNNING=$(docker ps -q | wc -l)
    echo "  Running containers: $RUNNING"
    
    # Check Docker Compose version
    if docker-compose version > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker Compose is working"
    fi
else
    echo -e "${RED}✗${NC} Docker daemon is NOT running"
    echo "  Start Docker with: sudo systemctl start docker"
    ((ERRORS++))
fi
echo ""

echo "7️⃣  Checking Git Repository"
echo "-----------------------------------"
if [ -d ".git" ]; then
    echo -e "${GREEN}✓${NC} Git repository initialized"
    BRANCH=$(git branch --show-current 2>/dev/null)
    REMOTE=$(git remote get-url origin 2>/dev/null)
    echo "  Current branch: $BRANCH"
    echo "  Remote: $REMOTE"
else
    echo -e "${YELLOW}⚠${NC} Not a git repository"
    ((WARNINGS++))
fi
echo ""

echo "8️⃣  Testing Docker Build (Optional)"
echo "-----------------------------------"
read -p "Do you want to test Docker build? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Building Docker image..."
    cd email
    if docker build -t email-service:test . > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker build successful"
        docker rmi email-service:test > /dev/null 2>&1
    else
        echo -e "${RED}✗${NC} Docker build failed"
        ((ERRORS++))
    fi
    cd ..
fi
echo ""

echo "========================================="
echo "📊 Summary"
echo "========================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You're ready to deploy! Try:"
    echo "  docker-compose up -d"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup OK with $WARNINGS warnings${NC}"
    echo ""
    echo "You can proceed, but review warnings above."
else
    echo -e "${RED}✗ Found $ERRORS errors and $WARNINGS warnings${NC}"
    echo ""
    echo "Please fix the errors before deploying."
    exit 1
fi

echo ""
echo "Next Steps:"
echo "1. Start local development: docker-compose up -d"
echo "2. Check health: curl http://localhost:8080/actuator/health"
echo "3. View logs: docker-compose logs -f"
echo "4. See DEPLOYMENT.md for more options"
echo ""
