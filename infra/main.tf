# ---------------------------------------------------------------------------
# S3 Bucket — Ticket Attachments & Reports
#
# This is the proof-of-concept resource for Delivery 1. It validates that
# the provider, credentials, and variable wiring are fully functional.
# In Delivery 2 it will be replaced by a proper storage module that adds
# versioning, lifecycle rules, and server-side encryption.
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "tickets" {
  bucket = "${var.project_name}-${var.environment}-attachments-${var.tickets_bucket_suffix}"

  # Allow Terraform to destroy the bucket even if it contains objects.
  # Acceptable in dev; will be set to false in prod via environment overrides.
  force_destroy = var.environment == "dev" ? true : false
}
