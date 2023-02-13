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
  public_key = file("/Users/Mohamed.Roble/Documents/Dev/keys/devenv.pub")

}


####  # ec2 instance 

resource "aws_instance" "arday_ec2" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.ubuntu_server.id
  # ami = data.aws_ami.amazon_linux_2.id
  # key_name      = aws_key_pair.pub_key.id
  key_name               = var.key_name1
  vpc_security_group_ids = var.security_group
  subnet_id              = var.pub_sn[count.index]
  # iam_instance_profile   = aws_iam_instance_profile.dev_ec2_profile.name
  iam_instance_profile = "ec2_profile"
  # user_data = file("./compute/userdata.tpl")
  user_data = var.user_data_file

  root_block_device {
    volume_size = var.vol_size
  }
  tags = {
    # Name = local.tmp.dev_generic_name["dev"]
    Name = "${var.server-name}${count.index + 1}"
    # Name = "Windows-server"

  }


}


## intance profile

# resource "aws_iam_instance_profile" "dev_ec2_profile" {
#   name = var.instance_profile
#   role = var.iam_role
# }