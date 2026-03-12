#!/bin/bash
# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Verify Python installation
python3 --version
pip3 --version

# Create symbolic links for convenience
ln -s /usr/bin/python3 /usr/bin/python 2>/dev/null || true
ln -s /usr/bin/pip3 /usr/bin/pip 2>/dev/null || true

# Install common Python packages
pip3 install --upgrade pip
pip3 install flask psycopg2-binary sqlalchemy

echo "Python and pip installation completed!"

# Install Docker
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Verify Docker installation
docker --version

echo "Docker installation completed!"

# Install Docker Compose
DOCKER_COMPOSE_VERSION="2.24.5"
curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
chmod +x /usr/local/bin/docker-compose

# Create symbolic link
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose 2>/dev/null || true

# Verify Docker Compose installation
docker-compose --version

echo "Docker Compose installation completed!"
echo "All installations completed successfully!"
echo "Note: You may need to log out and log back in for docker group changes to take effect."
