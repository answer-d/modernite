data "archive_file" "lambda_goodnight" {
  type = "zip"
  source_dir = "lambda/src/goodnight"
  output_path = "lambda/artifacts/goodnight.zip"
}

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

resource "aws_lambda_function" "goodnight" {
  filename = data.archive_file.lambda_goodnight.output_path
  function_name = "${var.prefix_name}-${var.system_name}-goodnight"
  role = aws_iam_role.lambda_goodnight.arn
  handler = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda_goodnight.output_base64sha256
  runtime = "python3.6"
  memory_size = 128
  timeout = 30

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-goodnight"
    Author = var.author
  }
}

resource "aws_cloudwatch_event_rule" "bedtime" {
  name = "${var.prefix_name}-${var.system_name}-bedtime"
  description = "Fires everyday @2:00 JST"
  schedule_expression = "cron(0 17 ? * * *)"

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-bedtime"
    Author = var.author
  }
}

resource "aws_cloudwatch_event_target" "goodnight" {
  rule = aws_cloudwatch_event_rule.bedtime.name
  target_id = "${var.prefix_name}-${var.system_name}-goodnight"
  arn = aws_lambda_function.goodnight.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_goodnight" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.goodnight.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.bedtime.arn
}
