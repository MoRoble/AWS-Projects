#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.arday_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_sng.*.name
}

# output "dev_security_group" {
#   value = [aws_security_group.["dev_sg"].id]
# }

output "instance_sg" {
  description = "select ec2 security group from locals variable in the root file"
  value       = [aws_security_group.arday-sg["ec2_sg"].id]
}

output "db_security_group" {
  value = [aws_security_group.arday-sg["database"].id]
}

output "security_group_wordpress" {
  value = [aws_security_group.arday-sg["wordpress"].id]
}

output "arday_peer_pub_rt" {
  value = aws_route_table.arday_pub_rt
}

output "arday_peer_pvt_rt" {
  value = aws_default_route_table.private_rt
}

output "public_subnets" {
  value = aws_subnet.arday_pub_sn.*.id
}

output "lb_public_subnets" {
  value = aws_subnet.arday_pub_sn.*.id
}

