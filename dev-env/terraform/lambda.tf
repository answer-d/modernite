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
