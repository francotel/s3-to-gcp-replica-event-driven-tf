resource "random_pet" "aws" {
  length = 1
}

locals {
  bucket-name = "s3-bucket-origen-${random_pet.aws.id}"
  sqs-name    = "sqs-origen-${random_pet.aws.id}"
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.2.0"

  name                = local.sqs-name
  create_queue_policy = true
  queue_policy_statements = {
    s3 = {
      sid     = "S3Publish"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["s3.amazonaws.com"]
        }
      ]
      conditions = [{
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.aws-account-id]
        },
        {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = [module.s3-bucket.s3_bucket_arn]
        }
      ]
    }
  }
}

module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.4.0"

  bucket                   = local.bucket-name
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  force_destroy            = var.s3-force-destroy

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "s3-notification" {
  bucket = module.s3-bucket.s3_bucket_id

  queue {
    events    = ["s3:ObjectCreated:*"]
    queue_arn = module.sqs.queue_arn
  }
}

resource "aws_s3_object" "files" {
  for_each = fileset("s3-objects/", "**/*.*")
  bucket   = module.s3-bucket.s3_bucket_id
  key      = each.value
  source   = "s3-objects/${each.value}"
  etag     = filemd5("s3-objects/${each.value}")
}