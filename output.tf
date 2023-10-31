output "website_hostname" {
  value = aws_s3_bucket_website_configuration.qscodingtest_config.website_endpoint
}

output "website_cloudfront_hostname" {
  value = aws_cloudfront_distribution.qscodingtest_s3_distribution.domain_name
}

