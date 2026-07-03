output "state_bucket_name" {
  value       = aws_s3_bucket.state_bucket.id
  description = "S3 Remote State Bucket Name"
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.state_bucket.arn
  description = "S3 Remote State Bucket ARN"
}
