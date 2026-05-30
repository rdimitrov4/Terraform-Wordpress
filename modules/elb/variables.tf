###############################
####         ELB           ####
###############################

variable "elb_security_group_id" {
  type        = string
  description = "Security group ID for the ELB"

}

variable "elb_health_check_target" {
  type        = string
  default     = "HTTP:80/"
  description = "The target for the ELB health check (e.g., HTTP:80/)"

}

variable "elb_health_check_interval" {
  type        = number
  default     = 30
  description = "The time between health checks of an individual instance (in seconds)"

}

variable "elb_health_check_timeout" {
  type        = number
  default     = 5
  description = "Amount of time in seconds, during which no response means a failed health check"
}

variable "elb_healthy_threshold" {
  type        = number
  default     = 2
  description = "Consecutive health checks successes number required before instance is considered healthy"

}

variable "elb_unhealthy_threshold" {
  type        = number
  default     = 2
  description = "Consecutive health check failures number required before instance is considered unhealthy"

}

###############################
####         VPC           ####
###############################

variable "subnets" {
  type        = list(string)
  description = "Public subnet IDs for the ELB"

}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"

}
