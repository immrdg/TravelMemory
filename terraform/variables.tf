variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name all resources."
  type        = string
  default     = "travelmemory"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "allowed_ssh_cidr" {
  description = "Your public IP in CIDR form, e.g. 203.0.113.7/32. Only this range can SSH to the web server."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) && var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "Provide a valid CIDR and do not use 0.0.0.0/0."
  }
}

variable "public_key_path" {
  description = "Path to the SSH PUBLIC key to register as the EC2 key pair."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_key_path" {
  description = "Path to the matching SSH PRIVATE key (only written into the Ansible inventory; never uploaded)."
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_user" {
  description = "Default login user of the AMI (Ubuntu)."
  type        = string
  default     = "ubuntu"
}

variable "web_instance_type" {
  description = "Web server size. The React build needs >= 2 GB RAM."
  type        = string
  default     = "t3.small"
}

variable "db_instance_type" {
  type    = string
  default = "t3.micro"
}
