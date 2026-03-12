#!/bin/bash
# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Verify installation
python3 --version
pip3 --version

# Create a symbolic link for convenience
ln -s /usr/bin/python3 /usr/bin/python
ln -s /usr/bin/pip3 /usr/bin/pip

# Install common Python packages that might be useful
pip3 install --upgrade pip
pip3 install flask mysql-connector-python pymysql

echo "Python and pip installation completed!"
