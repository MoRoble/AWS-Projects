####---- compute/outputs.tf


output "instance_public_dns" {
  description = "ALL DNS listed here"
  value       = aws_instance.arday_ec2[*].*.public_dns
}
output "instance_public_ip" {
  value = aws_instance.arday_ec2[*].public_ip
}

output "private-ip" {
  value = aws_instance.arday_ec2.*.private_ip
}

output "ec2-key" {
  value = aws_key_pair.pub_key.id
}
