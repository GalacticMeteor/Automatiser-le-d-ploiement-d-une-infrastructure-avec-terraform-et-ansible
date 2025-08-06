data "aws_vpc" "default" {
  default = true
}

# Fetch latest Amazon Linux 2023 AMI from AWS SSM Parameter Store
data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Define security groups and their custom TCP ports
locals {
  security_groups = {
    Docker_sg  = 8080
    Tomcat_sg  = 8080
    Jenkins_sg = 8080
    Ansible_sg = 8080
  }
}

resource "aws_security_group" "app_sg" {
  for_each    = local.security_groups
  name        = each.key
  description = "Security Group for ${each.key}"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP access
  ingress {
    description = "Allow Custom TCP for ${each.key}"
    from_port   = each.value
    to_port     = each.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Conditionally add HTTP (port 80) only for Ansiblesg
  dynamic "ingress" {
    for_each = each.key == "Ansiblesg" ? [1] : []
    content {
      description = "Allow HTTP for Ansiblesg"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress (allow all outbound)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define instances that will be created
resource "aws_instance" "app_instance" {
  for_each = local.security_groups

  ami           = each.key == "Tomcat_sg" ? data.aws_ssm_parameter.amazon_linux_2023_ami.value : var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app_sg[each.key].id]

  tags = {
    Name = "vm-${each.key}"
  }
}
