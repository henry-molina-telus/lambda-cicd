resource "aws_lambda_function" "api_lambda" {
  function_name    = "api"
  role             = aws_iam_role.api_lambda_role.arn
  s3_bucket        = aws_s3_bucket.api_bucket_040209405785.id
  s3_key           = aws_s3_object.api_code_archive.key
  source_code_hash = data.archive_file.api_code_archive.output_base64sha256
  /*
   * Architecture, runtime & handler might differ
	 * depending on the programming language you use
   */
  architectures = ["arm64"]
  runtime       = "nodejs20.x"
  handler       = "src/index.handler"
  memory_size   = 128
  publish       = true

  lifecycle {
    ignore_changes = [
      source_code_hash,
      environment
    ]
  }
}

/*
 * An alias allows us to point our
 * API gateway to a stable version of our function
 * which we can update as we want
 */
resource "aws_lambda_alias" "api_lambda_alias" {
  name             = "production"
  function_name    = aws_lambda_function.api_lambda.arn
  function_version = "$LATEST"

  lifecycle {
    ignore_changes = [
      function_version
    ]
  }
}
