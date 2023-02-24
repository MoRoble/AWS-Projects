# --- compute/variables.tf ---

variable "instance_count" {}
variable "instance_type" {}
variable "instance-sg" {}
variable "pub_sn" {}
variable "vol_size" {}
variable "key_name1" {
  # default = "new_key"
}
variable "server-name" {}
variable "key-file" {}
variable "user_data_file" {}

variable "iam_role" {}
variable "host_os" {}
variable "devtags" {
  type = map(any)
}

# variable "dbname" {}
# variable "dbuser" {}
# variable "dbpassword" {}