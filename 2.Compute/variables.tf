variable "app_port" {
  type        = number
  description = "The network port our production application code listens on internally"
  default     = 8080
}

variable "instance_type" {
  type        = string
  description = "Compute instance size for project Andrew web cluster"
  default     = "t3.medium"
}
