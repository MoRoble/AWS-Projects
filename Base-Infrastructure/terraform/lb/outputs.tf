####----- lb/outputs.tf

output "lb-tg-arn" {
  description = "to map the target group to the instance"
  value       = aws_lb_target_group.arday-tg.arn
}