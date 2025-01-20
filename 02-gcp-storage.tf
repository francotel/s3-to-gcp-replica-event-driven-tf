locals {
  gcp-bucket-name = "bucket-destination-${random_pet.aws.id}"
  iam-role-name   = "iam-role-transfer-${random_pet.aws.id}"
  iam-policy-name = "iam-policy-transfer-${random_pet.aws.id}"
}

data "google_storage_transfer_project_service_account" "default" {
  project = var.project-id
}

resource "aws_iam_role" "gcp-aws-federated-role" {
  name = local.iam-role-name

  # Update this section with the trust policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "accounts.google.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "accounts.google.com:sub" : data.google_storage_transfer_project_service_account.default.subject_id
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "iam-policy" {
  statement {
    sid = "AllowS3AccessTransfer"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.s3-bucket.s3_bucket_arn,
    "${module.s3-bucket.s3_bucket_arn}/*"]
  }
  statement {
    sid = "AllowSQSAccessTransfer"
    actions = [
      "sqs:receivemessage",
      "sqs:deletemessage"
    ]
    resources = [
    module.sqs.queue_arn]
  }
}

resource "aws_iam_policy" "iam-policy" {
  name   = local.iam-policy-name
  path   = "/"
  policy = data.aws_iam_policy_document.iam-policy.json
}

resource "aws_iam_role_policy_attachment" "aws-role-policy-attach" {
  role       = aws_iam_role.gcp-aws-federated-role.name
  policy_arn = aws_iam_policy.iam-policy.arn
}

module "gcs-bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 8.0"

  project_id               = var.project-id
  location                 = var.gcp-region
  name                     = local.gcp-bucket-name
  public_access_prevention = "enforced"
  force_destroy            = var.gcp-force-destroy
  autoclass                = false
  versioning               = false
  iam_members = [{
    role   = "roles/storage.legacyBucketWriter"
    member = data.google_storage_transfer_project_service_account.default.member
  }]
}

resource "google_storage_transfer_job" "s3-bucket-one-off" {
  description = "One-Off backup of S3 bucket"
  project     = var.project-id

  transfer_spec {
    transfer_options {
      delete_objects_unique_in_sink = false
      overwrite_when                = "DIFFERENT"
    }
    aws_s3_data_source {
      bucket_name = module.s3-bucket.s3_bucket_id
      role_arn    = aws_iam_role.gcp-aws-federated-role.arn
    }
    gcs_data_sink {
      bucket_name = module.gcs-bucket.name
    }
  }

  schedule {
    schedule_start_date {
      year  = 2025
      month = 1
      day   = 21
    }
    schedule_end_date {
      year  = 2025
      month = 1
      day   = 21
    }
    start_time_of_day {
      hours   = 23
      minutes = 30
      seconds = 0
      nanos   = 0
    }
  }

  lifecycle {
    ignore_changes = [
      transfer_spec[0].aws_s3_data_source[0].aws_access_key
    ]
  }

  depends_on = [
    module.s3-bucket.s3_bucket_id
  ]

}

resource "google_storage_transfer_job" "s3-bucket-event-driven" {
  description = "Event Driven backup of S3 bucket"
  project     = var.project-id

  transfer_spec {
    transfer_options {
      delete_objects_unique_in_sink = false
      overwrite_when                = "DIFFERENT"
    }
    aws_s3_data_source {
      bucket_name = module.s3-bucket.s3_bucket_id
      role_arn    = aws_iam_role.gcp-aws-federated-role.arn
    }
    gcs_data_sink {
      bucket_name = module.gcs-bucket.name
    }
  }

  event_stream {
    name = module.sqs.queue_arn
  }

  lifecycle {
    ignore_changes = [
      transfer_spec[0].aws_s3_data_source[0].aws_access_key
    ]
  }
  depends_on = [
    module.s3-bucket.s3_bucket_id
  ]
}