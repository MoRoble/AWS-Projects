# -- networking/main.tf ---

data "aws_availability_zones" "az" {}

resource "random_integer" "random" {
  min = 1
  max = 10
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.az.names
  result_count = var.max_subnets
}

## VPC ----

resource "aws_vpc" "arday_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    # Name = "Dev-Main-VPC"
    Name        = var.vpc_name
    Environment = var.envs
  }
  lifecycle {
    /* # the igw doesn't know where to go,
    # this lifecycle will create new vpc before existing vpc destroys so igw can reside
    */
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "arday_pub_assoc" {
  count     = var.pub_sn_count
  subnet_id = aws_subnet.arday_pub_sn.*.id[count.index]
  # subnet_id      = aws_subnet.dev_pub_sn1.id
  route_table_id = aws_route_table.arday_pub_rt.id
}

resource "aws_internet_gateway" "arday_igw" {
  vpc_id = aws_vpc.arday_vpc.id

  tags = {
    # Name = "arday-igw"
    Name = var.arday_igw
  }
}

resource "aws_route_table" "arday_pub_rt" {
  vpc_id = aws_vpc.arday_vpc.id

  tags = {
    # Name = "pub-rt"
    Name = var.pub_rt
  }
}

resource "aws_route" "default_rt" {
  route_table_id         = aws_route_table.arday_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.arday_igw.id
}

resource "aws_default_route_table" "private_rt" {
  #assigning default rt created by vpc to make our own default rt
  default_route_table_id = aws_vpc.arday_vpc.default_route_table_id

  tags = {
    # Name = "arday-pr-rt"
    Name = var.arday-pvt-rt
  }
}

resource "aws_security_group" "arday-sg" {
  for_each    = var.network_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.arday_vpc.id


  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### --- Subnets ----

resource "aws_subnet" "arday_pub_sn" {
  count                   = var.pub_sn_count
  vpc_id                  = aws_vpc.arday_vpc.id
  cidr_block              = var.pub_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${var.public_sn_tag}${count.index + 1}"
  }
}


resource "aws_subnet" "arday_app_sn" {
  count             = var.app_sn_count
  vpc_id            = aws_vpc.arday_vpc.id
  cidr_block        = var.app_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "app_sn_${count.index + 1}"
  }
}

resource "aws_subnet" "arday_db_sn" {
  count             = var.db_sn_count
  vpc_id            = aws_vpc.arday_vpc.id
  cidr_block        = var.db_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "db_sn_${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "rds_sng" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "rds_subnetgroup"
  subnet_ids = aws_subnet.arday_db_sn.*.id
  tags = {
    name = "db-sng"
  }
}
