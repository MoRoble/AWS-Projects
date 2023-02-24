####---- root / outputs.tf

output "ec2_public_dns" {
  value = flatten(module.compute.instance_public_dns)
}
output "ec2_public_ip" {
  value = module.compute.instance_public_ip
}

output "ec2_onprem_ip" {
  value = module.onprem_compute.instance_public_ip
}

####----iam outputs

# output ic2_role {
#   description = "to attach each instance profile"
#   value = module.iam.iam_role
# }