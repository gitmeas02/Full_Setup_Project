@echo off
REM DevOps Stack Setup Verification Script for Windows
REM This script checks if all required tools and configurations are present

echo =========================================
echo DevOps Stack Setup Verification
echo =========================================
echo.

setlocal enabledelayedexpansion
set ERRORS=0
set WARNINGS=0

REM Function to check command exists
:check_command
where %1 >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] %1 is installed
    if not "%~2"=="" (
        %1 %2 2>nul | findstr /r "."
    )
) else (
    echo [ERROR] %1 is NOT installed
    set /a ERRORS+=1
)
goto :eof

REM Function to check file exists
:check_file
if exist "%~1" (
    echo [OK] %~1 exists
) else (
    echo [ERROR] %~1 NOT found
    set /a ERRORS+=1
)
goto :eof

REM Function to check directory exists
:check_dir
if exist "%~1\" (
    echo [OK] %~1 exists
) else (
    echo [ERROR] %~1 NOT found
    set /a ERRORS+=1
)
goto :eof

echo 1. Checking Required Tools
echo -----------------------------------
call :check_command docker --version
call :check_command docker-compose --version
call :check_command java -version
call :check_command git --version
echo.

echo 2. Checking Optional Tools
echo -----------------------------------
where ansible >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] ansible is installed
) else (
    echo [WARNING] ansible is NOT installed (Optional for deployment)
    set /a WARNINGS+=1
)

where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] curl is installed
) else (
    echo [WARNING] curl is NOT installed (Recommended for testing)
    set /a WARNINGS+=1
)
echo.

echo 3. Checking Project Structure
echo -----------------------------------
call :check_file Jenkinsfile
call :check_file docker-compose.yml
call :check_file README.md
call :check_dir email
call :check_dir ansible
call :check_dir monitoring
call :check_file email\Dockerfile
call :check_file email\build.gradle
call :check_file ansible\deploy.yml
call :check_file ansible\setup.yml
call :check_dir ansible\inventory
call :check_file ansible\inventory\dev.ini
call :check_file ansible\inventory\staging.ini
call :check_file ansible\inventory\prod.ini
echo.

echo 4. Checking Gradle Wrapper
echo -----------------------------------
if exist "email\gradlew.bat" (
    echo [OK] Gradle wrapper exists
) else (
    echo [ERROR] Gradle wrapper NOT found
    set /a ERRORS+=1
)
echo.

echo 5. Checking Port Availability
echo -----------------------------------
netstat -an | find ":8080" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 8080 is already in use
    set /a WARNINGS+=1
) else (
    echo [OK] Port 8080 is available
)

netstat -an | find ":5432" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 5432 is already in use
    set /a WARNINGS+=1
) else (
    echo [OK] Port 5432 is available
)

netstat -an | find ":6379" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 6379 is already in use
    set /a WARNINGS+=1
) else (
    echo [OK] Port 6379 is available
)

netstat -an | find ":9090" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 9090 is already in use
    set /a WARNINGS+=1
) else (
    echo [OK] Port 9090 is available
)

netstat -an | find ":3000" | find "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 3000 is already in use
    set /a WARNINGS+=1
) else (
    echo [OK] Port 3000 is available
)
echo.

echo 6. Checking Docker Status
echo -----------------------------------
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker daemon is running
    
    for /f %%i in ('docker ps -q ^| find /c /v ""') do set RUNNING=%%i
    echo   Running containers: !RUNNING!
    
    docker-compose version >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Docker Compose is working
    )
) else (
    echo [ERROR] Docker daemon is NOT running
    echo   Start Docker Desktop from Start Menu
    set /a ERRORS+=1
)
echo.

echo 7. Checking Git Repository
echo -----------------------------------
if exist ".git\" (
    echo [OK] Git repository initialized
    for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set BRANCH=%%i
    for /f "tokens=*" %%i in ('git remote get-url origin 2^>nul') do set REMOTE=%%i
    echo   Current branch: !BRANCH!
    echo   Remote: !REMOTE!
) else (
    echo [WARNING] Not a git repository
    set /a WARNINGS+=1
)
echo.

echo 8. Testing Docker Build (Optional)
echo -----------------------------------
set /p BUILD="Do you want to test Docker build? (y/n): "
if /i "%BUILD%"=="y" (
    echo Building Docker image...
    cd email
    docker build -t email-service:test . >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Docker build successful
        docker rmi email-service:test >nul 2>&1
    ) else (
        echo [ERROR] Docker build failed
        set /a ERRORS+=1
    )
    cd ..
)
echo.

echo =========================================
echo Summary
echo =========================================
if %ERRORS% equ 0 if %WARNINGS% equ 0 (
    echo [OK] All checks passed!
    echo.
    echo You're ready to deploy! Try:
    echo   docker-compose up -d
) else if %ERRORS% equ 0 (
    echo [WARNING] Setup OK with %WARNINGS% warnings
    echo.
    echo You can proceed, but review warnings above.
) else (
    echo [ERROR] Found %ERRORS% errors and %WARNINGS% warnings
    echo.
    echo Please fix the errors before deploying.
    exit /b 1
)

echo.
echo Next Steps:
echo 1. Start local development: docker-compose up -d
echo 2. Check health: curl http://localhost:8080/actuator/health
echo 3. View logs: docker-compose logs -f
echo 4. See DEPLOYMENT.md for more options
echo.

endlocal
pause
