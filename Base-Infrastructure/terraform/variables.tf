##-----root/variables.tf

variable "host_os" {
  type = string
}

###----Common Vars
variable "aws_region" {
  description = "region to create resources"
  type        = string
}
variable "project_name" {
  description = "project name"
  type        = string
}
variable "environment" {
  description = "environment to deploy infrastructure"
  type        = string
}

###----Networking Vars ----
variable "access_ip" {
  type = string
}
variable "peer_owner_id" {}



variable "role_name" {
  default = "dev-wp"
}

variable "file_path" {}

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

variable "db" {}
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