output "gcp-bucket-name" {
  value = module.gcs-bucket.name
}

output "aws-role" {
  value = aws_iam_role.gcp-aws-federated-role.arn
}

output "aws-bucket-name" {
  value = module.s3-bucket.s3_bucket_id
}

output "aws-bucket-arn" {
  value = module.s3-bucket.s3_bucket_arn
}

output "aws-sqs-name" {
  value = module.sqs.queue_name
}