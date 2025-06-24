resource "aws_security_group" "allow_ssh_http" {
  name_prefix = "allow-ssh-http-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.allow_ssh_http.name]

user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "Starting user-data script at $(date)" | tee -a /var/log/user-data.log

    echo "Installing dependencies..." | tee -a /var/log/user-data.log
    apt update -y || { echo "Failed to run apt update" | tee -a /var/log/user-data.log; exit 1; }
    apt install -y openjdk-17-jdk wget unzip curl || { echo "Failed to install dependencies" | tee -a /var/log/user-data.log; exit 1; }

    echo "Ensuring 'jar' command is available..." | tee -a /var/log/user-data.log
    ln -sf /usr/lib/jvm/java-17-openjdk-amd64/bin/jar /usr/bin/jar || true

    echo "Checking Tomcat installation..." | tee -a /var/log/user-data.log
    if [ ! -f /opt/tomcat/bin/startup.sh ]; then
      echo "⬇️ Downloading Tomcat 10.1.18..." | tee -a /var/log/user-data.log
      cd /opt || { echo "Failed to cd /opt" | tee -a /var/log/user-data.log; exit 1; }
      rm -rf tomcat apache-tomcat-10.1.18.tar.gz
      wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz || { echo "Failed to download Tomcat" | tee -a /var/log/user-data.log; exit 1; }
      tar -xzf apache-tomcat-10.1.18.tar.gz || { echo "Failed to extract Tomcat" | tee -a /var/log/user-data.log; exit 1; }
      mv apache-tomcat-10.1.18 tomcat || { echo "Failed to move Tomcat directory" | tee -a /var/log/user-data.log; exit 1; }
      chmod +x /opt/tomcat/bin/*.sh || { echo "Failed to set executable permissions" | tee -a /var/log/user-data.log; exit 1; }
      rm apache-tomcat-10.1.18.tar.gz
      chown -R ubuntu:ubuntu /opt/tomcat || { echo "Failed to set permissions" | tee -a /var/log/user-data.log; exit 1; }
      echo "✅ Tomcat installed." | tee -a /var/log/user-data.log
    else
      echo "✅ Tomcat already installed. Skipping..." | tee -a /var/log/user-data.log
    fi

    echo "Starting Tomcat..." | tee -a /var/log/user-data.log
    /opt/tomcat/bin/startup.sh || { echo "Failed to start Tomcat" | tee -a /var/log/user-data.log; exit 1; }
    echo "User-data script completed at $(date)" | tee -a /var/log/user-data.log
  EOF
  tags = {
    Name = "JavaWebApp"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = "eipalloc-06cff5573d269a0c4"
}
