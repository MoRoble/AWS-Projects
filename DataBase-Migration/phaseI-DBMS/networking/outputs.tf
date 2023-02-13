#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.arday_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_sng.*.name
}

output "dev_security_group" {
  value = [aws_security_group.objs["dev_sg"].id]
}

output "db_security_group" {
  value = [aws_security_group.objs["database"].id]
}

output "security_group_wordpress" {
  value = [aws_security_group.objs["wordpress"].id]
}

output "arday_peer_pub_rt" {
  value = aws_route_table.arday_pub_rt
}

output "arday_peer_pvt_rt" {
  value = aws_default_route_table.private_rt
}

# output "dev_role" {
#   value = aws_iam_role.dev_wp_role.id
# }

output "public_subnets" {
  value = aws_subnet.arday_pub_sn.*.id
}

output "lb_public_subnets" {
  value = aws_subnet.arday_pub_sn.*.id
}

# output "iam_role"{
#   value = aws_iam_role.dev_wp_role.id
# }


