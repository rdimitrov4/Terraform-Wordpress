#!/bin/bash

########################################################
###  WordPress EC2 bootstrap script (Amazon Linux 2) ###
########################################################

# System Updates
yum update -y
yum upgrade -y

# Install Apache, PHP, and MySQL Client (Community Edition)
yum install -y httpd php php-mysqlnd php-fpm php-json php-gd php-xml php-mbstring

# Install MySQL Community Client (for RDS MySQL)
# Add MySQL repository
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
rpm -ivh mysql80-community-release-el7-3.noarch.rpm

# Install MySQL client
yum install -y mysql

amazon-linux-extras enable php8.0

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz -P /tmp
tar -xzf /tmp/latest.tar.gz -C /tmp
# Copy the WordPress files to /var/www/html/ recursively, including symbolic links, file permissions, user & group ownership (-a option)
rsync -av /tmp/wordpress/* /var/www/html/

# Configure WordPress
cd /var/www/html
cp wp-config-sample.php wp-config.php

# Set permissions
usermod -a -G apache ec2-user   
chown -R apache:apache /var/www/html
chown -R ec2-user:apache /var/www
chmod -R 755 /var/www/html

# Ensure that db_name, db_username, db_password, and db_endpoint are replaced (Terraform will template these)
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_username}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php
sed -i "s/localhost/${db_endpoint}/" wp-config.php

# Restart Apache
systemctl restart httpd

# CloudWatch Agent installation and configuration
yum install -y amazon-cloudwatch-agent

# Create CloudWatch Agent configuration for Amazon Linux 2
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_Idle", "unit": "Percent"},
          {"name": "cpu_usage_user", "rename": "CPU_User", "unit": "Percent"},
          {"name": "cpu_usage_system", "rename": "CPU_System", "unit": "Percent"}
        ],
        "totalcpu": true,
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "Memory_Used_Percent", "unit": "Percent"},
          {"name": "mem_available_percent", "rename": "Memory_Available_Percent", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "disk_used_percent", "rename": "Disk_Used_Percent", "unit": "Percent"}
        ],
        "resources": ["*"],
        "ignore_file_system_types": ["sysfs", "devtmpfs", "tmpfs"],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          {"name": "swap_used_percent", "rename": "Swap_Used_Percent", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "net": {
        "measurement": [
          {"name": "bytes_in", "rename": "Network_In_Bytes", "unit": "Bytes"},
          {"name": "bytes_out", "rename": "Network_Out_Bytes", "unit": "Bytes"}
        ],
        "resources": ["*"],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/messages"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/secure"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/cloud-init"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/cloud-init-output"
          },
          {
            "file_path": "/var/log/dnf.log",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/dnf"
          },
          {
            "file_path": "/var/log/hawkey.log",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/hawkey"
          },
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/httpd-access",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/wordpress",
            "log_stream_name": "{instance_id}/httpd-error"
          }
        ]
      }
    }
  }
}
EOF


# Start the CloudWatch Agent service
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# Enable the agent on boot
systemctl enable amazon-cloudwatch-agent
