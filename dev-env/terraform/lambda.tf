data "archive_file" "lambda_goodnight" {
  type        = "zip"
  source_dir  = "lambda/goodnight"
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
    timeout = 30

    tags = {
        Name = "${var.prefix_name}-${var.system_name}-goodnight"
        Author = var.author
    }
}

resource "aws_cloudwatch_event_rule" "bedtime" {
    name = "${var.prefix_name}-${var.system_name}-bedtime"
    description = "Fires everyday @2:00"
    schedule_expression = "cron(0 2 ? * * *)"

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
