###############################
####         VPC           ####
###############################

variable "aws_region" {
  default = "eu-west-1"

}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]

}

variable "vpc_cidr" {
  default = "10.0.0.0/16"

}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"

}

variable "webserver_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for webserver subnets"

}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"

}

###############################
####          RDS          ####
###############################

variable "db_name" {
  default = "db_wordpress"

}

variable "db_username" {
  default = "admin"

}

variable "db_password" {
  sensitive = true

}

###############################
####       EC2 - ASG       ####
###############################

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"

}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"

}

variable "key_name" {
  type        = string
  description = "SSH key-pair name for access to instances"

}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired instances in the ASG"
}

variable "max_capacity" {
  type        = number
  default     = 4
  description = "Maximum instances in the ASG"

}

variable "min_capacity" {
  type        = number
  default     = 1
  description = "Minimum instances in the ASG"

}
