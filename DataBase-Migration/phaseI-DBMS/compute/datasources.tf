
# Get the latest Windows Server 2022 AMI
data "aws_ami" "windows_server" {
  most_recent = true
  owners      = ["801119661308"]
  # owners = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

# Get latest Ubuntu Server
data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# # Amazon Linux Server

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["137112412989"]

#   filter {
#     name   = "name"
#     values = ["amazon/amzn2-ami-kernel-5.10-hvm-2.0.20230119.1-x86_64-gp2*"]
#   }
# }