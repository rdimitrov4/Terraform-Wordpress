#############################################
#### Launch Template config for the EC2s ####
#############################################

resource "aws_launch_template" "lt" {
  name_prefix   = "launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(templatefile("${path.module}/wordpress-userdata.sh", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_endpoint = var.rds_endpoint
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  network_interfaces {
    security_groups             = [var.ec2_security_group_id]
    associate_public_ip_address = false  # Make the instances have no public IPs
  }
  
  lifecycle {
    create_before_destroy = true
  }

}

###############################
####         ASG           ####
###############################

resource "aws_autoscaling_group" "asg" {
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity

  vpc_zone_identifier       = var.subnet_ids         # Subnets in which the ASG will deploy instances
  target_group_arns         = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "instance"
    propagate_at_launch = true
  }

}
