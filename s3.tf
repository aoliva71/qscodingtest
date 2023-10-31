

resource "aws_s3_bucket" "qscodingtest_bucket" {
  bucket = "qs-coding-test-2023-aol"

  tags = merge(var.base_tags, {
    Name        = "static website bucket"
  })
}

resource "aws_s3_bucket_ownership_controls" "qscodingtest_bucket_ownership_control" {
  bucket = aws_s3_bucket.qscodingtest_bucket.id
  rule {
    # this is to allow the acl
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "qscodingtest_block" {
  bucket = aws_s3_bucket.qscodingtest_bucket.id

  # unrestricted public access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "qscodingtest_bucket_acl" {
  # acl to allow reading the bucket
  depends_on = [
    aws_s3_bucket_ownership_controls.qscodingtest_bucket_ownership_control,
    aws_s3_bucket_public_access_block.qscodingtest_block,
  ]

  bucket = aws_s3_bucket.qscodingtest_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "qscodingtest_config" {
  # configuration to add "index.html" to the url path
  bucket = aws_s3_bucket.qscodingtest_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "qscodingtest_index_file" {
  # s3 object for index file
  bucket = aws_s3_bucket.qscodingtest_bucket.id
  key    = "index.html"
  content_type = "text/html"
  source = "htdocs/index.html"
  etag = filemd5("htdocs/index.html")
  acl = "public-read"

  depends_on = [
    aws_s3_bucket_acl.qscodingtest_bucket_acl
  ]

  tags = merge(var.base_tags, {
    Name        = "static website index file"
  })
}
