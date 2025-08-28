# AWS Provider
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.aws_provider_role_arn_wyexternal
  }
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      Project     = "wy-obs"
    }
  }
}

# Data source for latest Windows AMI
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for DCV access
resource "aws_security_group" "dcv" {
  name_prefix = "wy-obs-dcv-"
  description = "Security group for DCV access"

  ingress {
    description = "DCV"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "DCV UDP"
    from_port   = 8443
    to_port     = 8443
    protocol    = "udp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "wy-obs-dcv-sg"
    Environment = var.environment
    Project     = "wy-obs"
  }
}

# Windows EC2 instance with GPU
resource "aws_instance" "windows_gpu" {
  ami                    = data.aws_ami.windows.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.dcv.id]

  # UserData script for automatic software installation
  user_data = base64encode(templatefile("${path.module}/userdata.ps1", {
    # You can pass variables here if needed
  }))

  tags = {
    Name        = var.instance_name
    Project     = "wy-obs"
    Purpose     = "GPU streaming with OBS"
    Environment = var.environment
  }

  # Storage configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true

    tags = {
      Name        = "${var.instance_name}-root"
      Environment = var.environment
    }
  }
}
