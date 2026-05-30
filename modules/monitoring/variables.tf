variable "vpc_id" {
  description = "VPC ID for flow logs"
  type        = string

}

variable "rds_instance_id" {
  description = "RDS instance identifier (for log export)"
  type        = string

}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string

}


variable "alarm_actions" {
  description = "List of ARNs to notify on alarm"
  type        = list(string)
  default     = []

}

variable "elb_name" {
  type = string
  description = "Name of the ELB"

}
