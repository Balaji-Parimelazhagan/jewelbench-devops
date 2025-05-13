
# Create an S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# Configure Ownership Controls
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.object_ownership 
  }
}

# Set Access Control List (ACL)
resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_controls]
  bucket     = aws_s3_bucket.bucket.id
  acl        = var.acl 
}


# Block Public Access
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#Enable Server-Side Encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Uses AES-256 encryption (sse_algorithm = "AES256").
    }
  }
}

# Enable S3 Bucket as a Static Website
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}