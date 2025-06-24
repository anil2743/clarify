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

              echo "🔧 Installing dependencies..."
              apt update -y
              apt install -y openjdk-11-jdk wget unzip curl

              echo "✅ Setting up JAVA path..."
              export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
              export PATH="$JAVA_HOME/bin:$PATH"

              echo "📦 Installing Tomcat..."
              cd /opt
              rm -rf tomcat apache-tomcat-10.1.18 apache-tomcat-10.1.18.tar.gz
              wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz
              tar -xzf apache-tomcat-10.1.18.tar.gz
              mv apache-tomcat-10.1.18 tomcat
              chmod +x /opt/tomcat/bin/*.sh

              echo "📝 Creating deploy script..."
              cat << 'EOS' > /opt/deploy.sh
              #!/bin/bash
              set -e

              export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
              export PATH="$JAVA_HOME/bin:$PATH"

              echo "🛠 Ensuring directories exist..."
              mkdir -p /opt/tomcat/webapps
              mkdir -p /opt/tomcat/webapps/temp_root

              echo "🧹 Cleaning previous deployment..."
              rm -rf /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/ROOT.zip /opt/tomcat/webapps/temp_root/*

              echo "🌐 Downloading ROOT.zip..."
              curl -L -o /opt/tomcat/webapps/ROOT.zip "https://github.com/anil2743/clarify/releases/download/v1.0/ROOT.zip"

              echo "📦 Extracting WAR..."
              unzip /opt/tomcat/webapps/ROOT.zip -d /opt/tomcat/webapps/temp_root

              mkdir -p /opt/tomcat/webapps/ROOT
              cd /opt/tomcat/webapps/ROOT
              jar -xvf /opt/tomcat/webapps/temp_root/ROOT.war

              echo "🔁 Restarting Tomcat..."
              /opt/tomcat/bin/shutdown.sh || true
              sleep 3
              /opt/tomcat/bin/startup.sh || { echo "Tomcat startup failed"; exit 1; }

              echo "✅ Deployment completed at \$(date)" >> /opt/deploy.log
              EOS

              chmod +x /opt/deploy.sh

              echo "🚀 Running initial deployment..."
              bash /opt/deploy.sh
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
