output "endpoint" {
  value       = aws_db_instance.db.endpoint
  description = "RDS instance endpoint"

}

output "db_subnet_group" {
  value       = aws_db_subnet_group.db_subnet_group.name
  description = "Subnet group name for RDS instance"

}

output "rds_security_group_id" {
  value       = aws_security_group.rds_sg[*].id
  description = "ID of the SG for RDS access control"

}

output "db_instance_id" {
  value = aws_db_instance.db.id
  description = "ID of the RDS instance"

}
