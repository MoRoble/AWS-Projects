##-----root/variables.tf

variable "host_os" {
  type = string
}


variable "role_name" {
  default = "dev-wp"
}


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


#####---- IAM user varaiables

variable "devop_users" {
  type        = list(string)
  description = "Name of users to be created in  devops group"
}
variable "dev_users" {
  type        = list(string)
  description = "Names of users to be created in deveoper groups"
}
variable "spare_users" {
  type        = list(string)
  description = "Names of users to be created in spare-user group"
}
variable "prod_user" {
  type        = list(string)
  description = "Name of users for production account"
}


#-------database variables

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