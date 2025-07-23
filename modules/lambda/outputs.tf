output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.db_function.function_name
}

output "lambda_invoke_arn" {
  description = "ARN to invoke the Lambda function"
  value       = aws_lambda_function.db_function.invoke_arn
}