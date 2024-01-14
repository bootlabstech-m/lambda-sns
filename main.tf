# Lambda execution role resource
resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}-role"
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
  lifecycle {
    ignore_changes = [tags]
  }
}

# Lambda execution role policy resource
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "${var.name}-iam-policy"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
"Version": "2012-10-17",
"Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
]
}
EOF
  lifecycle {
    ignore_changes = [tags]
  }
}

# Lambda execution role policy attachment resource
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Lambda archive_file resource
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}

#  Lambda function resource
resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/python/hello-python.zip"
  function_name = var.name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  memory_size   = var.memory_size
  timeout       = var.timeout
  lifecycle {
    ignore_changes = [tags]
  }
}

# Creating Lambda permission resource
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_sns_topic.sns_topic[0].arn}"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "sns.amazonaws.com"

}


 
 
resource "aws_sns_topic" "sns_topic" {
  name                        = var.fifo_topic ? "${var.sns_topic_name}-${count.index + 1}.fifo" : "${var.sns_topic_name}-${count.index + 1}"
  delivery_policy             = var.delivery_policy
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  kms_master_key_id           = var.kms_master_key_id
  tracing_config              = var.tracing_config
  lifecycle {
    ignore_changes = [tags,delivery_policy,archive_policy]
  }
}
 
resource "aws_sns_topic_subscription" "subscription" {
  topic_arn                       = aws_sns_topic.sns_topic[0].arn
  protocol                        = var.protocol
  endpoint                        = aws_lambda_function.terraform_lambda_func.arn
  subscription_role_arn           = var.protocol == "firehose" ? var.subscription_role_arn : null
  endpoint_auto_confirms          = var.endpoint_auto_confirms
  confirmation_timeout_in_minutes = var.confirmation_timeout_in_minutes
    lifecycle {
    ignore_changes = [delivery_policy,filter_policy,redrive_policy]
  }
}