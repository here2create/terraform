#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

yum update -y
yum -y remove http*
yum install -y  --allowerasing --skip-broken http*
yum install -y  --allowerasing --skip-broken php8.*
yum install -y  --allowerasing --skip-broken mysql*
yum install -y  --allowerasing --skip-broken --best php8.*-mysqlnd

# Start and enable Apache using systemctl (preferred for Amazon Linux 2)
systemctl start httpd
systemctl enable httpd

#Creating new directories
mkdir /var/www
mkdir /var/www/html

# Modify file ownership and permissions
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Fetch EC2 instance metadata securely using Instance Metadata Service v2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id -o /var/www/html/index.html

# Download a PHP file from GitHub
cd /var/www/html
curl https://github.com/whoaadarsh/terraform/blob/main/index.php -O

# Ensure correct permissions for the downloaded PHP file
chown ec2-user:apache /var/www/html/index.php
chmod 664 /var/www/html/index.php