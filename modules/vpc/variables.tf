variable "availability_zones" {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
  description = "List of availability zones to be used for the subnets"

}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"

}

variable "webserver_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for webserver subnets"

}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"

}
