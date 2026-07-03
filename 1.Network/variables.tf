variable "vpc_cidr" {
  type        = string
  description = "The foundational CIDR block for Andrew production VPC"
  default     = "10.200.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Target deployment Availability Zones for high availability"
  default     = ["ap-south-1a", "ap-south-1b"]
}
