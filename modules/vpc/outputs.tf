output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"

}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "List of public subnet IDs"

}

output "webserver_subnet_ids" {
  value       = aws_subnet.webserver_subnet[*].id
  description = "List of webserver subnet IDs"

}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "List of private subnet IDs"

}

output "ec2_security_group_id" {
  value       = aws_security_group.ec2_sg.id
  description = "The security group ID for EC2 instances"

}
