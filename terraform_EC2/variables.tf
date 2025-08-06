variable "aws_region" {
  default = "eu-west-3"
}

variable "instance_count" {
  default = 4
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
}
