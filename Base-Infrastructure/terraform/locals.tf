locals {
  vpc_cidr = "10.16.0.0/16"
}



locals {
  select_sg = {
    ec2_sg = {
      name        = "arday-open-sg"
      description = "Arday EC2 public open Security group"
      ingress = {
        all = {
          desc        = "Open all ports"
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [var.access_ip]
        }

      }
    }
    alb_sg = {
      name        = "ALB-SG"
      description = "enable HTTP/S access on port 80/443"
      ingress = {
        http = {
          desc        = "http access"
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        https = {
          desc        = "https access"
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }

      }
    }
    wordpress = {
      name        = "dev-wp-sg"
      description = "Dev wordpress Security group"
      ingress = {
        ssh = {
          desc        = "Allow SSH IPv4 Trafficoos"
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          desc        = "Allow http IPv4 traffic"
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

      }
    }
    bastion = {
      name        = "Bastion SG"
      description = "enable SSH access on port 22 for Bastion EC2"
      ingress = {
        ssh = {
          desc        = "allow SSH access"
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip] #you can allow only your IP to make more secure
        }

      }
    }
    app_server = {
      name        = "App Server SG"
      description = "enable http/s access on 80/443 via ALB SG"
      ingress = {
        http = {
          desc     = "Allow http locally"
          from     = 80
          to       = 80
          protocol = "tcp"
          # security_group_id = [aws_security_group.arda]
          cidr_blocks = [local.vpc_cidr]
        }
        https = {
          desc        = "allow https locally"
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }

      }
    }
    database = {
      name        = "dev-db-sg"
      description = "Dev DB Security access"
      ingress = {
        mysql = {
          desc        = "Allow MySQL from App-server SG & Bastion SG"
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
          desc        = "Allow NFS/EFS IPv4 IN"
          from        = 2049
          to          = 2049
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }

      }
    }
  }
}