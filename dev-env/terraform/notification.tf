resource "aws_sns_topic" "default" {
  name = "${var.prefix_name}-${var.system_name}-${var.stage}"

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}"
    Author = var.author
    Stage = var.stage
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
  function_name = "${var.prefix_name}-${var.system_name}-${var.stage}-notify-teams"
  role = aws_iam_role.lambda_notify_teams.arn
  handler = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda_notify_teams.output_base64sha256
  runtime = "python3.6"
  memory_size = 128
  timeout = 10

  environment {
    variables = {
      TEAMS_WEBHOOK_URL_SSM_NAME = var.teams_webhook_url_ssm_name
    }
  }

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-notify-teams"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_cloudwatch_log_group" "lambda_notify_teams" {
  name = "/aws/lambda/${aws_lambda_function.notify_teams.function_name}"
  retention_in_days = 14

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-lambda-notify-teams"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_lambda_permission" "sns_notify_teams" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_teams.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.default.arn
}

data "aws_iam_policy_document" "assume_role_policy_lambda_notify_teams" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_notify_teams" {
  name = "${var.prefix_name}-${var.system_name}-${var.stage}-lambda-notify-teams"
  path = "/${var.prefix_name}-${var.system_name}-${var.stage}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda_notify_teams.json

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-lambda-notify-teams"
    Author = var.author
    Stage = var.stage
  }
}

resource "aws_iam_role_policy_attachment" "notify_teams_lambda_basic_execution" {
  role = aws_iam_role.lambda_notify_teams.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "notify_teams_ssm_ro" {
  role = aws_iam_role.lambda_notify_teams.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "notify_teams_cloudwatchlogs_ro" {
  role = aws_iam_role.lambda_notify_teams.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}


resource "aws_cloudwatch_log_metric_filter" "goodnight_anomaly" {
  name = "${var.prefix_name}-${var.system_name}-${var.stage}-goodnight-notify"
  pattern = "{$.loglevel = \"WARNING\" || $.loglevel = \"ERROR\"}"
  log_group_name = "/aws/lambda/${aws_lambda_function.goodnight.function_name}"

  metric_transformation {
    name = "goodnight-notify"
    namespace = "${var.prefix_name}/${var.system_name}/${var.stage}/Lambda"
    value = "1"
  }

  depends_on = [aws_cloudwatch_log_group.lambda_goodnight]
}

resource "aws_cloudwatch_metric_alarm" "goodnight_anomaly" {
  alarm_name = "${var.prefix_name}-${var.system_name}-${var.stage}-goodnight-notify"
  statistic = "SampleCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold = 0
  evaluation_periods = 1
  namespace = aws_cloudwatch_log_metric_filter.goodnight_anomaly.metric_transformation[0].namespace
  metric_name = aws_cloudwatch_log_metric_filter.goodnight_anomaly.metric_transformation[0].name
  period = 10
  datapoints_to_alarm = 1
  alarm_description = "Alarm for goodnight lambda"
  actions_enabled = true
  alarm_actions = [aws_sns_topic.default.arn]
  treat_missing_data = "notBreaching"

  tags = {
    Name = "${var.prefix_name}-${var.system_name}-${var.stage}-goodnight-notify"
    Author = var.author
    Stage = var.stage
  }
}
