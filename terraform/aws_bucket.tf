data "aws_iam_role" "admin_role" {
  name = "AWSReservedSSO_AdministratorAccess_ecc4385902a6e053"
}

resource "aws_s3_bucket" "hosting_bucket" {
  bucket = local.domain

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_website_configuration" "hosting_bucket" {
  bucket = aws_s3_bucket.hosting_bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "hosting_bucket" {
  bucket = aws_s3_bucket.hosting_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "hosting_bucket" {
  bucket = aws_s3_bucket.hosting_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "hosting_bucket" {
  bucket = aws_s3_bucket.hosting_bucket.id

  # Allow us to set a bucket policy permitting readonly public access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "hosting_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.hosting_bucket,
    aws_s3_bucket_public_access_block.hosting_bucket,
  ]

  bucket = aws_s3_bucket.hosting_bucket.id
  acl    = "public-read"
}

data "aws_iam_policy_document" "hosting_bucket" {
  statement {
    sid    = "RequireEncryptedStorage"
    effect = "Deny"
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.hosting_bucket.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "AES256",
      ]
    }
  }

  statement {
    sid    = "AllowAdmin"
    effect = "Allow"
    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.hosting_bucket.arn,
      "${aws_s3_bucket.hosting_bucket.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_iam_role.admin_role.arn
      ]
    }
  }

  statement {
    sid    = "AllowRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.hosting_bucket.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid    = "AllowCloudflareRead"
    effect = "Deny"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.hosting_bucket.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"

      values = data.cloudflare_ip_ranges.cloudflare.cidr_blocks
    }
  }
}

resource "aws_s3_bucket_policy" "hosting_bucket" {
  bucket = aws_s3_bucket.hosting_bucket.id
  policy = data.aws_iam_policy_document.hosting_bucket.json
}
