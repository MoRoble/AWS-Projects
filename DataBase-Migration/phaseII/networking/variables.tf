# --- networking/variables.tf--

variable "vpc_name" {
  type = string
}

variable "role_name" {}

variable "envs" {
  type = string
}

variable "pub_rt" {
  type = string
}

variable "arday_igw" {}
variable "arday-pvt-rt" {}
variable "public_sn_tag" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "pub_cidrs" {
  type = list(any)
}

variable "app_cidrs" {
  type = list(any)
}

variable "db_cidrs" {
  type = list(any)
}

variable "pub_sn_count" {
  type = number
}

variable "app_sn_count" {
  type = number
}

variable "db_sn_count" {
  type = number
}

variable "max_subnets" {
  type = number
}

variable "access_ip" {
  type = string
}
variable "network_sg" {}


variable "db_subnet_group" {
  type = bool
}

