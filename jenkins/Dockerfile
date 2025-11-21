FROM jenkins/jenkins:lts-jdk21

# Switch to root to install packages
USER root

# Install Docker CLI, Docker Compose, Ansible, and other tools
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    ansible \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Install Trivy for security scanning
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins \
    docker-workflow \
    docker-plugin \
    ansible \
    git \
    workflow-aggregator \
    pipeline-stage-view \
    sonar \
    jacoco \
    junit \
    email-ext \
    credentials-binding \
    ssh-agent \
    blueocean

# Create Jenkins user in docker group (will map to host docker group)
RUN groupadd -g 999 docker || true && usermod -aG docker jenkins

# Switch back to jenkins user
USER jenkins

# Set environment variables
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Skip initial setup wizard
ENV JENKINS_OPTS="--httpPort=8080"
