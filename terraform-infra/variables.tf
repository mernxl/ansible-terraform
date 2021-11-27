variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS Region to deploy to"
}

variable "aws_creds_profile" {
  type        = string
  default     = "ansible-terraform"
  description = "AWS credentials profile to use"
}

variable "aws_ec2_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "AWS EC2 instance type, target freetier for region"
}
