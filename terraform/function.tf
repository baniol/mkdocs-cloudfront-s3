resource "aws_cloudfront_function" "mkdocs" {
  name = "RewriteDefaultIndexRequest"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite index.html"
  publish = true
  code    = file("${path.module}/function.js")
}