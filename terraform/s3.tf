/*
 * Data blocks request that Terraform read from a given data source
 * and export the result under the given local
 * Here we're creating a zip archive to be used below
 */
data "archive_file" "api_code_archive" {
  type        = "zip"
  source_dir = "${path.root}/../src"
  output_path = "${path.root}/../src.zip"
}

// S3 bucket in which we're gonna release our versioned zip archives
resource "aws_s3_bucket" "api_bucket_040209405785" {
  bucket        = "api-bucket-040209405785"
  force_destroy = true
}

/*
 * The first archive is uploaded through Terraform
 * The following ones will be uploaded by our CI/CD. pipeline in GitHub actions
 */
resource "aws_s3_object" "api_code_archive" {
  bucket = aws_s3_bucket.api_bucket_040209405785.id
  key    = "src.zip"
  source = data.archive_file.api_code_archive.output_path
  etag   = filemd5(data.archive_file.api_code_archive.output_path)

  lifecycle {
    ignore_changes = [
      etag
    ]
  }
}
