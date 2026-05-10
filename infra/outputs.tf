output "tickets_bucket_name" {
  description = "Name of the S3 bucket that stores ticket attachments and generated reports. Used by compute modules (Lambda/ECS) as a target for uploads and downloads."
  value       = aws_s3_bucket.tickets.bucket
}

output "tickets_bucket_arn" {
  description = "ARN of the S3 bucket for ticket attachments. Referenced in IAM policies to grant least-privilege access to compute and async processing roles."
  value       = aws_s3_bucket.tickets.arn
}
