resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    content = <<EOF
import json
import pg8000
import os

def lambda_handler(event, context):
    try:
        conn = pg8000.connect(
            host=os.environ['DB_HOST'],
            database=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD']
        )

        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()

        cursor.close()
        conn.close()

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Database connection successful',
                'db_version': str(db_version[0])
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
EOF
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "db_function" {
  # filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-db-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  filename         = "${path.module}/lambda_function.zip"
  # source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  runtime         = "python3.9"
  timeout         = 30

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      DB_HOST     = split(":", var.db_endpoint)[0]
      DB_NAME     = "webapp"
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
  ]
}