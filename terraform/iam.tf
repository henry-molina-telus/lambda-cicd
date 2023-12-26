resource "aws_iam_role" "api_lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

/*
 * Add a policy to our role
 * to be able to push logs from our function
 */
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-role-policy"
  role = aws_iam_role.api_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

/*
 * Allow our API gateway to invoke our function
 */
resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  qualifier     = aws_lambda_alias.api_lambda_alias.name
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

data "aws_iam_policy_document" "ecr_policy_data" {
  statement {
    sid    = "ECR Policy for CI/CD"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["040209405785"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:GetAuthorizationToken"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = data.aws_iam_policy_document.ecr_policy_data.json
}