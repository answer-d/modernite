data "aws_iam_policy_document" "assume_role_policy_lambda_goodnight" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_goodnight" {
  name = "${var.prefix_name}-${var.system_name}-lambda-goodnight"
  path = "/${var.prefix_name}-${var.system_name}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda_goodnight.json

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-lambda-goodnight"
    Author = var.author
  }
}

resource "aws_iam_role_policy_attachment" "goodnight_lambda_basic_execution" {
  role = aws_iam_role.lambda_goodnight.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "goodnight_ec2_ro" {
  role = aws_iam_role.lambda_goodnight.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy_document" "policy_lambda_goodnight_stop_my_instances" {
  statement {
    sid = "LambdaGoodnightStopMyInstances"
    actions = ["ec2:StopInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test = "StringEquals"
      variable = "ec2:ResourceTag/Author"
      values = [var.author]
    }
  }
}

resource "aws_iam_policy" "lambda_goodnight_stop_my_instances" {
  name = "${var.prefix_name}-${var.system_name}-lambda-goodnight-stop-my-instances"
  path = "/${var.prefix_name}-${var.system_name}/"
  policy = data.aws_iam_policy_document.policy_lambda_goodnight_stop_my_instances.json
}

resource "aws_iam_role_policy_attachment" "goodnight_stop_my_instances" {
  role = aws_iam_role.lambda_goodnight.id
  policy_arn = aws_iam_policy.lambda_goodnight_stop_my_instances.arn
}


data "archive_file" "lambda_goodnight" {
  type = "zip"
  source_dir = "lambda/src/goodnight"
  output_path = "lambda/artifacts/goodnight.zip"
}

resource "aws_lambda_function" "goodnight" {
  filename = data.archive_file.lambda_goodnight.output_path
  function_name = "${var.prefix_name}-${var.system_name}-goodnight"
  role = aws_iam_role.lambda_goodnight.arn
  handler = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda_goodnight.output_base64sha256
  runtime = "python3.6"
  memory_size = 128
  timeout = 10

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
