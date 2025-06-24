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

            echo "📦 Installing dependencies..."
            apt update -y
            apt install -y openjdk-11-jdk wget unzip curl -y

            echo "🔧 Creating required directories..."
            mkdir -p /opt
            mkdir -p /opt/tomcat/webapps
            mkdir -p /opt/tomcat/webapps/temp_root

            echo "🔗 Ensuring 'jar' command is available..."
            ln -sf /usr/lib/jvm/java-11-openjdk-amd64/bin/jar /usr/bin/jar || true

            echo "🧰 Checking for Tomcat installation..."
            if [ ! -f /opt/tomcat/bin/startup.sh ]; then
              echo "⬇️ Downloading and setting up Tomcat..."
              cd /opt
              rm -rf tomcat
              wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz
              tar -xvzf apache-tomcat-10.1.18.tar.gz
              mv apache-tomcat-10.1.18 tomcat
              chmod +x /opt/tomcat/bin/*.sh
            else
              echo "✅ Tomcat already installed, skipping..."
            fi
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
