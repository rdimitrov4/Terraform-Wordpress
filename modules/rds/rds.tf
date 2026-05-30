resource "aws_db_instance" "db" {
  db_name                         = var.db_name
  username                        = var.db_username
  password                        = var.db_password
  instance_class                  = var.db_instance_class
  engine                          = var.db_engine
  engine_version                  = var.db_engine_version
  allocated_storage               = var.db_allocated_storage  
  backup_retention_period         = var.db_backup_retention_period
  multi_az                        = var.db_multi_az
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot             = true
  publicly_accessible             = false

  # CloudWatch Logging
  parameter_group_name            = aws_db_parameter_group.rds_logging.name
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name = "db-rds"
  }

}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "db-subnet-group"
  }

}

resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id

  # Allow inbound MySQL traffic from EC2 instances from the VPC's webserver subnets
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.webserver_subnet_cidrs
  }

  # Allow outbound traffic for the RDS instances
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds"
  }

}

#########################################
####      RDS Parameter Group        ####
#########################################

resource "aws_db_parameter_group" "rds_logging" {
  name        = "rds-logging-mysql"
  family      = "mysql${var.db_engine_version}"
  description = "Enable MySQL logging to CloudWatch"

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "1"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  tags = {
    Name = "rds-logging-mysql"
  }
}
