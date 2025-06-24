resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${path.module}/terraform1.pub")
}

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
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = var.instance_type
  key_name               = var.key_name
  security_groups        = [aws_security_group.allow_ssh_http.name]

  user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-11-jdk wget unzip

              cd /opt
              wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.83/bin/apache-tomcat-9.0.83.tar.gz
              tar -xvzf apache-tomcat-9.0.83.tar.gz
              mv apache-tomcat-9.0.83 tomcat
              chmod +x /opt/tomcat/bin/*.sh

              wget https://github.com/anil2743/clarify/releases/latest/download/ROOT.war -O /opt/tomcat/webapps/ROOT.war

              /opt/tomcat/bin/startup.sh
              EOF

  tags = {
    Name = "JavaWebApp"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
}
