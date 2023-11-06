###----compute/main.tf ----

resource "random_id" "arday_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name1
    # ami = data.aws_ami.ubuntu_server.id
  }
}


## SSM parameters for the  key pair 
# resource "aws_ssm_parameter" "key_path" {
#   name        = "/dev/global/instance/key-pair"
#   description = "The ssh public key pair"
#   type        = "SecureString"
#   value       = local.tmp.ssmp_placeholder_default_value
#   tags        = var.devtags
#   lifecycle {
#     ignore_changes = [value]
#   }
# }


##### key pair

resource "aws_key_pair" "pub_key" {
  key_name = var.key_name1
  # key_name = "arday-key-nc"
  # public_key = aws_ssm_parameter.key_path.value
  # public_key = file("C:/Users/M ROBLE/.ssh/arday.pub")
  public_key = var.pub-key-file
}



####  # ec2 instance 

/* - using ubuntu as it is one of the best Linux distros for use on
Desktops or Servers, making it incredibly accessible.
*/

resource "aws_instance" "arday_ec2" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.ubuntu_server.id
  # ami = data.aws_ami.amazon_linux_2.id
  # key_name      = aws_key_pair.pub_key.*.id
  key_name               = var.key_name1
  vpc_security_group_ids = var.instance-sg
  subnet_id              = var.pub_sn[count.index]
  # iam_instance_profile = "ec2_profile"
  # iam_instance_profile = var.iam_role
  # user_data = file("./compute/userdata.tpl")
  user_data = var.user_data_file
  /*user_data = templatefile("${path.module}${var.user_data_file}", {
    dbname = var.dbname,
    # dbuser     = var.dbuser,
    dbpassword = var.dbpassword,
  })*/

  root_block_device {
    volume_size = var.vol_size
  }
  tags = {
    Name = "${var.server-name}${count.index + 1}"
    # Name = "Windows-server"
  }


}


## intance profile

# resource "aws_iam_instance_profile" "dev_ec2_profile" {
#   name = var.instance_profile
#   role = var.iam_role
# }

resource "aws_lb_target_group_attachment" "arday-tg-attach" {
  count            = var.instance_count
  target_group_arn = var.lb-tg-arn
  target_id        = aws_instance.arday_ec2[count.index].id
  port             = 8000 #map instance port directly
}