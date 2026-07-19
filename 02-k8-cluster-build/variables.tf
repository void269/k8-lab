// VPC Vars
variable "cidr_block" {
  description = "VPC CIDR Block"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "aws_az_list" {
  description = "List of Availability Zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

//EC2 Vars
variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "env" {
  description = "Environment"
  type = string
  default = "test1"
}

variable "ami_image_id" {
  description = "AMI ID for Ubuntu Linux EC2 Instance"
  type = string
  default = "ami-0b6d9d3d33ba97d99"
}

variable "ec2_instance_type_worker" {
  description = "EC2 Instance Type for Worker Nodes"
  type = string
  default = "t3.medium"
}

variable "ec2_instance_type_control_plane" {
  description = "EC2 Instance Type for Control Plane Node"
  type = string
  default = "t3.medium"
}

/*
variable "access_key" {
  description = "IAM access key"
  type = string
  sensitive = true
}

variable "secret_key" {
  description = "IAM secret key"
  type = string
  sensitive = true
}
*/
variable "ssh_key" {
  description = "SSH Key to access EC2 instances"
  type = string
  default = "Demo-key-01"
}

variable "ssh_key_path" {
  description = "Path to SSH key"
  type = string
  default = "P:\\Classes\\Perdue - Cloud DevOps\\Demo-key-01.pem"
}

variable "username" {
  description = "Username for SSH access to EC2 instances"
  type = string
  default = "ubuntu"
}

// Kubernetes vars
variable "k8_version" {
  description = "Kubernetes Version"
  type = string
  default = "1.36"
}

variable "pod_cidr" {
  description = "Kubernetes Version"
  type = string
  default = "192.168.0.0/16"
}