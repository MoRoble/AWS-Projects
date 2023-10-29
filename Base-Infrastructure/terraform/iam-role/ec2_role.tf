#### ---- iam-role/ec2_role ----

resource "aws_iam_instance_profile" "arday_ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.dev_wp_role.name
}


## Policy document
data "aws_iam_policy_document" "dev_policy_doc" {
  # description = "SSM access"
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess",
      # - "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/AmazonSSMFullAccess",

    ]
  }
}

resource "aws_iam_role" "dev_wp_role" {
  name = "arday_ec2_profile_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowWordPressApplication"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "wp_role"
  }
}

## I am policy
resource "aws_iam_policy" "dev_wp_role" {
  name = "dev-wp"
  #   name        = var.role_name
  path        = "/"
  description = "A policy for ec2 profile role"
  policy      = data.aws_iam_policy_document.dev_policy_doc.json

}

## Policy attachement
resource "aws_iam_role_policy_attachment" "dev-assoc" {
  role       = aws_iam_role.dev_wp_role.name
  policy_arn = aws_iam_policy.dev_wp_role.arn
}


## to check if sometimes the role already created in your account

# resource "null_resource" "check_role_existence" {
#   triggers = {
#     role_name = aws_iam_role.dev_wp_role.name
#   }

#   provisioner "local-exec" {
#     command = "if ! aws iam get-role --role-name ${var.role_name} >/dev/null 2>&1; then exit 1; fi"
#   }
# }