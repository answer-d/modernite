resource "aws_iam_role" "lambda_goodnight" {
    name = "${var.prefix_name}-${var.system_name}-lambda-goodnight"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

    tags = {
        Name = "${var.prefix_name}-${var.system_name}-lambda-goodnight"
        Author = var.author
    }
}

resource "aws_iam_role_policy" "lambda_goodnight" {
    name = "${var.prefix_name}-${var.system_name}-lambda-goodnight"
    role = aws_iam_role.lambda_goodnight.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StopInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "StringEquals": {"ec2:ResourceTag/Author": "${var.author}"}
            }
        }
    ]
}
EOF
}
