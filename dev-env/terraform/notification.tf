resource "aws_sns_topic" "default" {
  name = "${var.prefix_name}-${var.system_name}"

  tags = {
    Name = "${var.prefix_name}-${var.system_name}"
    Author = var.author
  }
}

resource "aws_sns_topic_subscription" "teams" {
  topic_arn = aws_sns_topic.default.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.notify_teams.arn
}

data "archive_file" "lambda_notify_teams" {
  type = "zip"
  source_dir = "lambda/src/notify_teams"
  output_path = "lambda/artifacts/notify_teams.zip"
}

resource "aws_lambda_function" "notify_teams" {
  filename = data.archive_file.lambda_notify_teams.output_path
  function_name = "${var.prefix_name}-${var.system_name}-notify-teams"
  role = aws_iam_role.lambda_notify_teams.arn
  handler = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda_notify_teams.output_base64sha256
  runtime = "python3.6"
  memory_size = 128
  timeout = 30

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-notify-teams"
    Author = var.author
  }
}

resource "aws_lambda_permission" "sns_notify_teams" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_teams.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.default.arn
}

resource "aws_iam_role" "lambda_notify_teams" {
  name = "${var.prefix_name}-${var.system_name}-lambda-notify-teams"
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
    Name = "${var.prefix_name}-${var.system_name}-lambda-notify-teams"
    Author = var.author
  }
}

resource "aws_iam_role_policy" "lambda_notify_teams" {
  name = "${var.prefix_name}-${var.system_name}-lambda-notify-teams"
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
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_metric_filter" "goodnight_notify" {
  name = "${var.prefix_name}-${var.system_name}-goodnight-notify"
  pattern = "{$.Notify = 'true'}"
  log_group_name = "/aws/lambda/${aws_lambda_function.goodnight.function_name}"

  metric_transformation {
    name = "EventCount"
    namespace = "yama/LogMetric"
    value = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "goodnight_notify" {
  alarm_name = "${var.prefix_name}-${var.system_name}-goodnight-notify"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = aws_cloudwatch_log_metric_filter.goodnight_notify.name
  alarm_description = "Ararm for goodnight lambda"
  alarm_actions = [aws_sns_topic.default.arn]

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-goodnight-notify"
    Author = var.author
  }
}
