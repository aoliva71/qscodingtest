

locals {
  origin = "qscodingtest_origin"
}

resource "aws_cloudfront_origin_access_control" "qscodingtest_cf_acl" {
  # access control
  name                              = "qscodingtest_cf_acl"
  description                       = "qs coding test cloudfront access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "qscodingtest_s3_distribution" {
  # configure distribution to edge locations
  origin {
    domain_name              = aws_s3_bucket.qscodingtest_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.qscodingtest_cf_acl.id
    origin_id                = local.origin
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 600
    max_ttl                = 3600
  }

  # allow distribution to a bunch of regions
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB", "IR", "IT", "ES", "FR", "GR", "PT", "AU", "NZ"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.base_tags, {
    "regions" = "GB IT ES FR GR PT AU NZ"
  })
}

