output "elb_dns_name" {
  value       = aws_lb.elb.dns_name
  description = "DNS name of the ALB"

}

output "elb_zone_id" {
  value       = aws_lb.elb.zone_id
  description = "Canonical hosted zone ID of the ALB"

}

output "elb_security_group_id" {
  value       = aws_security_group.sg_elb.id
  description = "The security group ID for the ALB"

}

output "target_group_arn" {
  value       = aws_lb_target_group.tg.arn
  description = "ARN of the WordPress Target Group"

}

output "elb_arn" {
  value       = aws_lb.elb.arn
  description = "ARN of the ALB"

}

output "elb_name" {
  value       = aws_lb.elb.name
  description = "Name of the ALB"

}
