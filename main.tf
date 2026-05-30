provider "aws" {
  region = var.aws_region

}

module "vpc" {
  source = "./modules/vpc"

  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  webserver_subnet_cidrs = var.webserver_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs

}

module "elb" {
  source = "./modules/elb"

  subnets               = module.vpc.public_subnet_ids
  elb_security_group_id = module.elb.elb_security_group_id
  vpc_id                = module.vpc.vpc_id

}

module "rds" {
  source = "./modules/rds"

  db_subnet_ids          = module.vpc.private_subnet_ids
  db_security_groups     = module.rds.rds_security_group_id
  db_subnet_group        = module.rds.db_subnet_group
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  vpc_id                 = module.vpc.vpc_id
  vpc_security_group_ids = module.rds.rds_security_group_id
  webserver_subnet_cidrs = var.webserver_subnet_cidrs

}

module "ec2" {
  source = "./modules/ec2"

  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  desired_capacity      = var.desired_capacity
  max_capacity          = var.max_capacity
  min_capacity          = var.min_capacity
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  rds_endpoint          = module.rds.endpoint
  subnet_ids            = module.vpc.webserver_subnet_ids
  ec2_security_group_id = module.vpc.ec2_security_group_id
  target_group_arn      = module.elb.target_group_arn

}

module "monitoring" {
  source                 = "./modules/monitoring"

  vpc_id                 = module.vpc.vpc_id
  autoscaling_group_name = module.ec2.asg_name
  rds_instance_id        = module.rds.db_instance_id
  elb_name               = module.elb.elb_name
  # alarm_actions          = [aws_sns_topic.alerts.arn]

}
