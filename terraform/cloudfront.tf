# resource "aws_s3_bucket" "b" {
#   bucket = "mybucket"

#   tags = {
#     Name = "My bucket"
#   }
# }

# resource "aws_s3_bucket_acl" "b_acl" {
#   bucket = aws_s3_bucket.b.id
#   acl    = "private"
# }

locals {
  s3_origin_id = "BaniolMkDocsOrigin"
}

resource "aws_cloudfront_origin_access_control" "mkdocs" {
  name                              = "mkdocs"
  description                       = "Mkdocs policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "mkdocs-distribution" {
  origin {
    domain_name = aws_s3_bucket.mkdocs.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    origin_access_control_id = aws_cloudfront_origin_access_control.mkdocs.id

    # s3_origin_config {
    #   origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "MkDocs template"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

#   aliases = ["mkdocs.shiftbits.net"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association {
      event_type = "viewer-request"
      function_arn = aws_cloudfront_function.mkdocs.arn
    }
  }

  # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/content/immutable/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false
#       headers      = ["Origin"]

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

  # Cache behavior with precedence 1
#   ordered_cache_behavior {
#     path_pattern     = "/content/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}