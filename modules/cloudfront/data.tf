# Define an IAM policy document for allowing CloudFront to access S3 objects
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${var.s3_arn}/*",
      "${var.s3_arn}"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [aws_cloudfront_distribution.cf_dist.arn]
    }
  }
}


# Attach an S3 bucket policy to control access
resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy" {
  bucket = var.s3_name
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}
