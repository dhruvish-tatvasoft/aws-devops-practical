terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "demo-devops-terraform-state-bucket"     # Replace with your S3 bucket name
    key            = "aws-devops-practical/terraform.tfstate" # Path inside the bucket
    region         = "ap-south-1"                             # S3 bucket region
    dynamodb_table = "terraform-locks"                        # Optional, for state locking
    encrypt        = true                                     # Optional, encrypts state at rest
  }
}

provider "aws" {
  region = var.aws_region
}



# Security group allowing ssh and http
resource "aws_security_group" "terraform_sg" { # use underscores
  name        = "terraform-sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # correct attribute name is cidr_blocks
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "NodeAppServer" {
  ami             = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04 LTS in ap-south-1
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.terraform_sg.name]
  user_data       = <<-EOF
              #!/bin/bash
              # Install docker
              apt-get update
              apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              add-apt-repository \
                 "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                 $(lsb_release -cs) \
                 stable"
              apt-get update
              apt-get install -y docker-ce
              usermod -aG docker ubuntu

              # Install docker-compose
              curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Install CloudWatch Agent for Docker metrics
              apt-get install -y amazon-cloudwatch-agent

              # Create CloudWatch config
              cat <<EOT > /opt/aws/amazon-cloudwatch-agent/bin/config.json
              {
                "metrics": {
                  "namespace": "NodeApp",
                  "metrics_collected": {
                    "docker": {
                      "metrics_collection_interval": 60,
                      "resources": ["*"]
                    }
                  }
                }
              }
              EOT

              # Start CloudWatch Agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
              EOF

  tags = {
    Name = "NodeAppServer"
  }
}

