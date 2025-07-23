variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN to invoke the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}