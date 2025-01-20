data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

locals {
  aws-account-id = data.aws_caller_identity.current.account_id
  aws-region     = data.aws_region.current.name
}