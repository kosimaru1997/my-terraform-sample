data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "distribution-to-alb" {
  
  enabled = true

  origin {
    domain_name = var.alb_dns
    origin_id   = var.alb_id
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    custom_header {
      name  = "X-Custom-Header"
      value = "custom-value-1111"
    }
  }

  default_cache_behavior {
    target_origin_id       = var.alb_id
    cache_policy_id = data.aws_cloudfront_cache_policy.CachingDisabled.id

    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["HEAD", "GET"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    # forwarded_values {
    #   headers      = ["*"]
    #   query_string = true
    #   cookies {
    #     forward = "all"
    #   }
    # }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

#   logging_config {
#     bucket          = aws_s3_bucket.access_log_bucket.bucket_domain_name
#     include_cookies = "true"
#     prefix          = "/sample-app/"
#   }
}
