#### ---- iam-role/ec2_role ----

resource "aws_iam_instance_profile" "arday_ec2_profile" {
  name = "ArdayZone-ec2_profile"
  role = aws_iam_role.arday_dev_role.name
}



resource "aws_iam_role" "arday_dev_role" {
  name = "ardayZone-SSM-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    "Name" = "ec2-SSM-role-assume"
  }
}

data "aws_iam_policy" "arday_dev_policy" {
  ## I got error, I wanted to attach multiple policies to this role
  # for_each = list([
  #   "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  #   "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess",
  #   # - "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  #   "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  # ])
  # arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  arn = "arn:aws:iam::aws:policy/AdministratorAccess" # to give full access to all resources
  # arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  # arn = each.value
}

resource "aws_iam_role_policy_attachment" "ssmCoreAttach" {
  role       = aws_iam_role.arday_dev_role.name
  policy_arn = data.aws_iam_policy.arday_dev_policy.arn
}



## Policy document
# data "aws_iam_policy_document" "arday_dev_policy_doc" {
#   # description = "SSM access"
#   statement {
#     sid = "1"

#     # effect = "Allow"
#     actions = [
#       "sts:AssumeRole"
#     ]

#     resources = [
#       "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
#       "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess",
#       # - "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
#       "arn:aws:iam::aws:policy/AmazonSSMFullAccess",

#     ]
#   }
# }


## I am policy
# resource "aws_iam_policy" "arday_dev_policy" {
#   name = "ArayZone-dev-policy"
#   #   name        = var.role_name
#   path        = "/"
#   description = "A policy for ec2 profile role"
#   policy      = data.aws_iam_policy_document.arday_dev_policy_doc.json

# }

## Policy attachement
# resource "aws_iam_role_policy_attachment" "dev-assoc" {
#   role       = aws_iam_role.arday_dev_role.name
#   policy_arn = aws_iam_policy.arday_dev_policy.arn
# }

#### WordPress role
# resource "aws_iam_role" "dev_wp_role" {
#   name = "arday_ec2_profile_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "AllowWordPressApplication"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = {
#     tag-key = "wp_role"
#   }
# }



## to check if sometimes the role already created in your account

# resource "null_resource" "check_role_existence" {
#   triggers = {
#     role_name = aws_iam_role.dev_wp_role.name
#   }

#   provisioner "local-exec" {
#     command = "if ! aws iam get-role --role-name ${var.role_name} >/dev/null 2>&1; then exit 1; fi"
#   }
# }