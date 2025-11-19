variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name (as registered in AWS console)"
  type        = string
  default     = "my-key-pair" # <-- change to your key pair name (no .pem)
}
