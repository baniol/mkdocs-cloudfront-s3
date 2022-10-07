resource "aws_s3_bucket" "mkdocs" {
  bucket = "baniol-mkdocs-resources"

  tags = {
    Name        = "baniol-mkdocs-resources"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "mkdocs" {
  bucket = aws_s3_bucket.mkdocs.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.mkdocs.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

resource "aws_s3_bucket_public_access_block" "mkdocs" {
  bucket = aws_s3_bucket.mkdocs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {

    sid = "AllowFromCloudfront"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      format("%s/*", aws_s3_bucket.mkdocs.arn)
    ]

    condition {
      test = "StringEquals"
      variable =  "AWS:SourceArn"
      values = [aws_cloudfront_distribution.mkdocs-distribution.arn]
    }
  }
}