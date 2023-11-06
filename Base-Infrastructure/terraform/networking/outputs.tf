#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.arday_vpc.id
}
##--db module outputs
output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_sng.*.name
}

##--- instance outputs
output "instance_sg" {
  description = "select ec2 security group from locals variable in the root file"
  value       = [aws_security_group.arday-sg["ec2_sg"].id]
}
output "ec2-pub-sn" {
  description = "Public EC2's launched subents"
  value       = aws_subnet.arday_pub_sn.*.id
}
# output "iam_role"{
#   value = aws_iam_role.dev_wp_role.id
# }

###---- db outputs
output "db_security_group" {
  value = [aws_security_group.arday-sg["database"].id]
}

### lb outputs
output "alb_open_sg" {
  value = [aws_security_group.arday-sg["alb_sg"].id]
}
output "alb_pub_subnets" {
  value = aws_subnet.arday_pub_sn.*.id
}

###---- other outputs
output "arday_peer_pub_rt" {
  value = aws_route_table.arday_pub_rt
}

output "arday_peer_pvt_rt" {
  value = aws_default_route_table.private_rt
}

# output "dev_role" {
#   value = aws_iam_role.dev_wp_role.id
# }

# output "lb_public_subnets" {
#   value = aws_subnet.arday_pub_sn.*.id
# }



