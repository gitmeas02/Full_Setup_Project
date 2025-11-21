pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'email-service'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        SONARQUBE_ENV = 'SonarQube'
        GIT_REPO = 'https://github.com/gitmeas02/Full_Setup_Project.git'
        APP_DIR = 'email'
    }
    
    tools {
        gradle 'Gradle-8.5'
        jdk 'JDK-21'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
                echo 'Code checked out successfully'
            }
        }
        
        stage('Build') {
            steps {
                dir("${APP_DIR}") {
                    script {
                        echo 'Building the application...'
                        sh './gradlew clean build -x test'
                    }
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                dir("${APP_DIR}") {
                    script {
                        echo 'Running unit tests...'
                        sh './gradlew test'
                    }
                }
            }
            post {
                always {
                    junit "${APP_DIR}/**/build/test-results/test/*.xml"
                    jacoco execPattern: "${APP_DIR}/**/build/jacoco/*.exec"
                }
            }
        }
        
        stage('Code Quality Analysis') {
            steps {
                dir("${APP_DIR}") {
                    script {
                        echo 'Running SonarQube analysis...'
                        withSonarQubeEnv("${SONARQUBE_ENV}") {
                            sh './gradlew sonarqube'
                        }
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir("${APP_DIR}") {
                    script {
                        echo 'Building Docker image...'
                        dockerImage = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                        docker.build("${DOCKER_IMAGE}:latest")
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    echo 'Scanning Docker image for vulnerabilities...'
                    sh """
                        trivy image --severity HIGH,CRITICAL \
                        --format template --template '@/contrib/html.tpl' \
                        -o trivy-report.html ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'trivy-report.html',
                        reportName: 'Trivy Security Report'
                    ])
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    echo 'Pushing Docker image to registry...'
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        dockerImage.push("${DOCKER_TAG}")
                        dockerImage.push("latest")
                    }
                }
            }
        }
        
        stage('Deploy to Dev') {
            steps {
                script {
                    echo 'Deploying to Development environment...'
                    ansiblePlaybook(
                        playbook: 'ansible/deploy.yml',
                        inventory: 'ansible/inventory/dev.ini',
                        extras: "-e docker_tag=${DOCKER_TAG}",
                        credentialsId: 'ansible-ssh-key'
                    )
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                dir("${APP_DIR}") {
                    script {
                        echo 'Running integration tests...'
                        sh './gradlew integrationTest'
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Deploying to Staging environment...'
                    ansiblePlaybook(
                        playbook: 'ansible/deploy.yml',
                        inventory: 'ansible/inventory/staging.ini',
                        extras: "-e docker_tag=${DOCKER_TAG}",
                        credentialsId: 'ansible-ssh-key'
                    )
                }
            }
        }
        
        stage('Approval for Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Deploying to Production environment...'
                    ansiblePlaybook(
                        playbook: 'ansible/deploy.yml',
                        inventory: 'ansible/inventory/prod.ini',
                        extras: "-e docker_tag=${DOCKER_TAG}",
                        credentialsId: 'ansible-ssh-key'
                    )
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            emailext(
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Good news! The build ${env.BUILD_URL} completed successfully.",
                to: 'team@example.com'
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext(
                subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Build ${env.BUILD_URL} failed. Please check the logs.",
                to: 'team@example.com'
            )
        }
        always {
            cleanWs()
        }
    }
}
