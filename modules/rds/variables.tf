###############################
####         RDS           ####
###############################

variable "db_name" {
  type        = string
  default     = "db_wordpress"
  description = "The name of the database"

}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "Master username for the RDS instance"

}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password for the RDS instance"

}

variable "db_engine" {
  type        = string
  default     = "mysql"
  description = "Database engine type to use (eg. - mariadb, postgres, mysql)"

}

variable "db_engine_version" {
  type        = string
  default     = "5.7"
  description = "Database engine version to use"

}

variable "db_multi_az" {
  type        = bool
  default     = true
  description = "Ebable/Disable Multi-AZ deployment for the RDS instance"

}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class (eg. - db.t3.micro)"

}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Storage, in GB, RDS instance gets allocated "

}

variable "db_backup_retention_period" {
  type        = number
  default     = 7
  description = "The number of days to retain backups for the RDS instance"

}

variable "db_subnet_group" {
  type        = string
  description = "The DB subnet group for the RDS instance, must include only private subnets"

}

variable "db_security_groups" {
  type        = list(string)
  description = "List of security groups assigned to the RDS instance"

}

variable "db_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the RDS subnet group"

}

###############################
####         VPC           ####
###############################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"

}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of VPC security group IDs for the RDS instance"

}

variable "webserver_subnet_cidrs" {
  type = list(string)
  description = "Webserver subnet CIDR blocks for DB's security group"

}
