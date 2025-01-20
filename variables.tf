variable "project-id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "gcp-region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "aws-region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws-profile" {
  description = "AWS Profile"
  type        = string
}

variable "s3-force-destroy" {
  description = "Delete Bucket"
  default     = true
}

variable "gcp-force-destroy" {
  description = "Delete Cloud Storage"
  default     = true
}