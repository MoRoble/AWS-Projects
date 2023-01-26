#### our Serverless Application Roles

## state machine role - step function -

resource "aws_iam_role" "StateMachineRole" {
  name = "StateMachineRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatchlogsSM" {
  name = "StateMachineCloudwatchlogs_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "invokelambdaSM" {
  name = "StateMachineInvokelambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction",
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatchlogs-attach" {
  role       = aws_iam_role.StateMachineRole.name
  policy_arn = aws_iam_policy.cloudwatchlogsSM.arn
}

resource "aws_iam_role_policy_attachment" "invokelambdasandsendSNS" {
  role       = aws_iam_role.StateMachineRole.name
  policy_arn = aws_iam_policy.invokelambdaSM.arn
}


#### Role & Policy for email_reminder_lambda

resource "aws_iam_role" "LambdaRole" {
  name = "LambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_cloudwatchlogs" {
  name = "Lambda-cloudwatchlogs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*",
      },
    ],
  })
}

resource "aws_iam_policy" "Lambda_sns" {
  name = "Lambda-snsandsespermissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ses:*", "sns:*", "states:*"],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "Lambda_cloudwatchlogsAttach" {
  role       = aws_iam_role.LambdaRole.name
  policy_arn = aws_iam_policy.lambda_cloudwatchlogs.arn
}

resource "aws_iam_role_policy_attachment" "Lambda_snsandsespermissionsAttach" {
  role       = aws_iam_role.LambdaRole.name
  policy_arn = aws_iam_policy.Lambda_sns.arn
}