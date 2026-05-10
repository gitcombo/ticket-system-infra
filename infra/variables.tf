variable "environment" {
  description = "Deployment environment. Controls naming, sizing, and retention policies across all resources."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either 'dev' or 'prod'."
  }
}

variable "project_name" {
  description = "Name of the project. Used as a prefix in all resource names to avoid collisions across projects in the same AWS account."
  type        = string
  default     = "ticket-system"
}

variable "region" {
  description = "AWS region where all resources will be provisioned. Choose a region close to your primary user base."
  type        = string
  default     = "us-east-1"
}

variable "tickets_bucket_suffix" {
  description = "Suffix appended to the S3 bucket name for ticket attachments and reports. Must be globally unique across all AWS accounts. Use a short random string or your team identifier."
  type        = string
  default     = "galileo-pdds"
}
