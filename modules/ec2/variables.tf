variable "ami_id" {
  type        = string
  description = "AMI ID for instances"

}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"

}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in the ASG"

}

variable "max_capacity" {
  type        = number
  description = "Maximum number of instances in the ASG"

}

variable "min_capacity" {
  type        = number
  description = "Minimum number of instances in the ASG"

}

variable "key_name" {
  type        = string
  description = "The SSH key pair name to use for SSH access to EC2 instances"

}

variable "rds_endpoint" {
  type        = string
  description = "RDS endpoint for the database"

}

variable "db_name" {
  type        = string
  description = "Database name for WordPress"

}

variable "db_username" {
  type        = string
  description = "Database username for WordPress"

}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password for WordPress"

}

variable "target_group_arn" {
  type        = string
  description = "ARN of the Target Group where instances will be attached"

}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ASG"

}

variable "ec2_security_group_id" {
  type        = string
  description = "SG ID for EC2 instances"

}
