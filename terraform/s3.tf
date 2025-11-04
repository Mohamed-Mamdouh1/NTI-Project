resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "elb_logs" {
  bucket        = "nti-alb-access-logs-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "nti-alb-logs"
  }
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
  bucket = aws_s3_bucket.elb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSALBLoggingPermissions"
        Effect    = "Allow"
        Principal = {
          Service = "logdelivery.elb.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.elb_logs.arn}/*"
      }
    ]
  })
}
