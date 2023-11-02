####---networking NAT GateWay

resource "aws_eip" "eip1" {
  domain = "vpc"
  #   vpc = true ## depricated
  count = var.pub_sn_count

  tags = {
    Name = "${var.project_name}-${var.environment}-eip${count.index + 1}"
  }
}
resource "aws_nat_gateway" "public-natgw" {
  count         = var.pub_sn_count
  allocation_id = aws_eip.eip1[count.index].id
  subnet_id     = aws_subnet.arday_pub_sn[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-Pub-natGW${count.index + 1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.arday_igw]
}

resource "aws_route_table" "private-nat-rt" {
  count  = var.pub_sn_count
  vpc_id = aws_vpc.arday_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-natgw.*.id[count.index]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-pvt-nat-rt${count.index + 1}"
  }
}

### same way of doing the job but using diferent functions
resource "aws_route_table_association" "private-nat-app-rt-ass" {
  count = length(var.app_cidrs)
  subnet_id      = element(aws_subnet.arday_app_sn.*.id, count.index)
  route_table_id = aws_route_table.private-nat-rt[0].id
}

resource "aws_route_table_association" "privat-nat-db-rt-ass" {
  count          = var.db_sn_count
  subnet_id      = aws_subnet.arday_db_sn.*.id[count.index]
  route_table_id = aws_route_table.private-nat-rt[1].id
}