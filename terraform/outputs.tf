output "cf_arn" {
    value = aws_cloudfront_distribution.mkdocs-distribution.arn
}

output "cf_domain" {
    value = aws_cloudfront_distribution.mkdocs-distribution.domain_name
}