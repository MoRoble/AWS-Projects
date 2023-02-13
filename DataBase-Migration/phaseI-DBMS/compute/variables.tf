# --- compute/variables.tf ---

variable "instance_count" {}
variable "instance_type" {}
variable "security_group" {}
variable "pub_sn" {}
variable "vol_size" {}
variable "key_name1" {
  # default = "new_key"
}
variable "server-name" {}
# variable "instance_profile" {

# }
variable "user_data_file" {}
# variable private-ip {
#   type = string
#   value = aws_instance.arday_ec2.private_ip
# }
# variable "iam_role" {}
variable "host_os" {}
variable "devtags" {
  type = map(any)

}
