###------root/main.tf ------

# resource "random_integer" "random" {
#   # count            = var.instance_count
#   min = 1
#   max = 101
# }

module "cloud_VPC" {
  source          = "./networking"
  vpc_name        = "cloud-Arday-VPC"
  public_sn_tag   = "pub_sn_"
  pub_rt          = "cloud_rt"
  arday_igw       = "Arday-cloud-igw"
  arday-pvt-rt    = "cloud-pvt-rt"
  role_name       = var.role_name
  vpc_cidr        = local.vpc_cidr
  pub_sn_count    = 3
  app_sn_count    = 3 #var.app_account
  db_sn_count     = 3
  pub_cidrs       = [for i in range(4) : cidrsubnet(local.vpc_cidr, 4, i)]
  app_cidrs       = [for i in range(4, 8) : cidrsubnet(local.vpc_cidr, 4, i)]
  db_cidrs        = [for i in range(8, 12) : cidrsubnet(local.vpc_cidr, 4, i)]
  max_subnets     = 10
  access_ip       = var.access_ip
  network_sg      = local.select_sg
  db_subnet_group = "true"
  envs            = "on_cloud_arday"
  environment     = var.environment
  project_name    = var.project_name
  # sn-azA = [
  #   "aws_subnet.arday_app_sn[0].id",
  #   "aws_subnet.arday_db_sn[0].id"
  # ]

}

# module "onprem_VPC" {
#   source          = "./networking"
#   vpc_name        = "onprem-Arday-VPC"
#   public_sn_tag   = "onprem_"
#   pub_rt          = "onprem_rt"
#   arday-pvt-rt    = "onprem-pvt-rt"
#   arday_igw       = "Arday-onprem-igw"
#   role_name       = var.role_name
#   vpc_cidr        = "192.168.10.0/24"
#   pub_sn_count    = 1
#   pub_cidrs       = ["192.168.10.0/24"]
#   network_sg      = local.select_sg
#   db_subnet_group = "false"
#   db_sn_count     = 0
#   app_sn_count    = 0
#   app_cidrs       = ["false"]
#   db_cidrs        = ["false"]
#   max_subnets     = 5
#   access_ip       = "false"
#   envs            = "onpremises_arday"

# }


module "compute" {
  source         = "./compute"
  instance-sg    = module.cloud_VPC.instance_sg
  pub_sn         = module.cloud_VPC.ec2-pub-sn
  instance_count = 2
  instance_type  = "t3.micro"
  vol_size       = "30"
  key_name1      = "arday-cloud" #-key created on cloud side
  host_os        = var.host_os
  devtags        = var.devtags
  # dbname     = var.dbname
  # dbuser     = var.dbuser
  # dbpassword = var.dbpassword
  # instance_profile = module.ec2_profile
  user_data_file = file("${var.file_path["userdata_basic"]}")
  # user_data_file = file("./compute/userdata_wp.tpl")
  pub-key-file = file("${var.file_path["key-file"]}")
  iam_role     = module.ec2_profile.ec2_profile_name
  server-name  = "clooud-server_"
  lb-tg-arn    = module.lb.lb-tg-arn

}

###---- instance profile
module "ec2_profile" {
  source = "./iam-role"
  # ec2_profile = "arday_ec2_role_profile"
}

#### DataBase module is ready
# module "database" {
#   source                 = "./database"
#   db_engine_version      = "10.6.11"
#   db_instance_class      = "db.t3.micro"
#   dbname                 = var.db["name"]
#   dbuser                 = var.db["user"]
#   dbpassword             = var.db["password"]
#   db_identifier          = "arday-db-id"
#   snapshot_identifier    = "arday-ecs-final-snapshot"
#   skip_db_snapshot       = true
#   db_subnet_group_name   = module.cloud_VPC.db_subnet_group_name[0]
#   vpc_security_group_ids = module.cloud_VPC.db_security_group
# }

####----- load balance
module "lb" {
  source = "./lb"
  # lb_count = 1
  lb_sg                   = module.cloud_VPC.alb_open_sg
  lb_pub_sn               = module.cloud_VPC.alb_pub_subnets
  tg_port                 = 80 #8000 to reach instance port 8000
  tg_protocol             = "HTTP"
  vpc_id                  = module.cloud_VPC.vpc_id
  elb_healthy_threshold   = 2
  elb_unhealthy_threshold = 2
  elb_timeout             = 3
  elb_interval            = 30
  listener_port           = 80 # to access publicly #8000 for k8s
  listener_protocol       = "HTTP"
}


### Establish private connectivity between VPC's

# resource "aws_vpc_peering_connection" "peer-between" {
#   peer_owner_id = var.peer_owner_id
#   peer_vpc_id   = module.cloud_VPC.vpc_id
#   vpc_id        = module.onprem_VPC.vpc_id
#   auto_accept   = true

#   tags = {
#     Name = "Arday onprem to cloud"
#   }
# }

### Create rout on cloud_VPC

# resource "aws_route" "peer-cloud-rt" {
#   route_table_id            = module.cloud_VPC.arday_peer_pub_rt.id
#   destination_cidr_block    = "192.168.10.0/24"
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer-between.id
# }

# resource "aws_route" "peer-cloud-pvt-rt" {
#   route_table_id            = module.cloud_VPC.arday_peer_pvt_rt.id
#   destination_cidr_block    = "192.168.10.0/24"
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer-between.id
# }

### Create rout on onprem_VPC

# resource "aws_route" "peer-onprem-rt" {
#   route_table_id            = module.onprem_VPC.arday_peer_pub_rt.id
#   destination_cidr_block    = "10.16.0.0/16"
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer-between.id
# }




# module "iam" {
#   source        = "./iam"
#   devop_users   = var.devop_users
#   dev_users     = var.dev_users
#   users-spare   = var.spare_users
#   devtags       = var.devtags
#   product_users = var.prod_user
# }


# module "s3" {
#   source  = "./s3"
#   s3_name = "arday-bck-lambdas"
#   acl     = "private"
# }