###############################
#### CloudWatch Log Groups ####
###############################

# Log Group for EC2 Agent logs
resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/wordpress"
  retention_in_days = 1

}

# Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc" {
  name              = "flowlogsgroup-wordpress"
  retention_in_days = 1

}

############################
####    VPC FlowLogs    ####
############################

resource "aws_iam_role" "flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })

}

resource "aws_flow_log" "vpc_flowlog" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc.arn
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  vpc_id               = var.vpc_id
  traffic_type         = "ALL"
  # Requires better log formatting

}



############################
####  CloudWatch Alarms ####
############################

resource "aws_cloudwatch_metric_alarm" "ec2_asg_cpu_high" {
  alarm_name          = "ASGHighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when average CPU of the ASG exceeds 80%"
#   alarm_actions       = var.alarm_actions

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "RDSHighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors RDS CPU usage"
#   alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

}

resource "aws_cloudwatch_metric_alarm" "elb_latency_high" {
  alarm_name          = "ELBHighLatency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Latency"
  namespace           = "AWS/ELB"
  period              = 300
  statistic           = "Average"
  threshold           = 0.5
  alarm_description   = "This metric monitors ELB latency"
#   alarm_actions       = var.alarm_actions

  dimensions = {
    LoadBalancerName = var.elb_name
  }

}
