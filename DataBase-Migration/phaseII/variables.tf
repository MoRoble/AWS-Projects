##-----root/variables.tf

variable "host_os" {
  type = string
}


variable "role_name" {
  default = "dev-wp"
}

variable "file_path" {}

variable "peer_owner_id" {}

variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "access_ip" {
  type = string
}

variable "app_account" {
  type    = number
  default = 3
}
variable "bucketnames" {}


#-------database variables

variable db {}
variable "dbname" {
  type = string
}
variable "dbuser" {
  type = string
}
variable "dbpassword" {
  type      = string
  sensitive = true
}
variable "dbrootpassword" {
  type      = string
  sensitive = true
}
variable "devtags" {
  type = map(any)
}