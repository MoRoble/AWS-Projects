locals {
  vpc_cidr = "10.16.0.0/16"
}

# locals {
#   private-ip4 = module.onprem_compute.private-ip
# }

locals {
  security_groups = {
    dev_sg = {
      name        = "dev-main-sg"
      description = "Dev main public open Security group"
      ingress = {
        all = {
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [var.access_ip]
        }
      }
    }
    wordpress = {
      name        = "dev-wp-sg"
      description = "Dev wordpress Security group"
      ingress = {
        ssh = {
          description = "Allow SSH IPv4 Trafficoos"
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          description = "Allow http IPv4 traffic"
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    database = {
      name        = "dev-db-sg"
      description = "Dev DB Security access"
      ingress = {
        mysql = {
          description = "Allow MySQL IN"
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
    efs = {
      name        = "dev-efs-sg"
      description = "Dev EFS Security Group"
      ingress = {
        nfs = {
          description = "Allow NFS/EFS IPv4 IN"
          from        = 2049
          to          = 2049
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}