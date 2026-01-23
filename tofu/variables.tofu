variable "account_id" {
  description = "The AWS Account ID"
}

variable "pac_role" {
  description = "The IAM role for Platform deployment"
}

variable "s3_backend" {
  description = "The S3 bucket name for OpenTofu remote state backend"
}

variable "aws_region" {
  description = "The AWS region"
}

variable "db_master_username" {
  description = "The master username for the RDS database"
  default     = "root"
  sensitive   = true
}

variable "db_master_password" {
  description = "The master password for the RDS database"
  sensitive   = true
}

variable "hp_dev_s3_bucket" {
  description = "The S3 bucket name for hariprasad.dev website hosting"
  default     = ""
}

# Variables for YAML templating
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "awsing"
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for CloudFront"
  type        = string
  default     = ""
}