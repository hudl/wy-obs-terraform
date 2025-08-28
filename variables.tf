variable "region" {
  description = "AWS region for EC2 instance"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type with GPU support"
  type        = string
  default     = "g4dn.xlarge"
}

variable "key_name" {
  description = "AWS key pair name for DCV access"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for DCV access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "wy-obs-gpu-instance"
}

variable "aws_provider_role_arn_wyexternal" {
  type        = string
  description = "AWS role provider wyexternal"
  default     = "arn:aws:iam::858373385149:role/TerraformRunner"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "beta"
}
