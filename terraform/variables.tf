variable "env" {
  type        = string
  description = "Deployment environment name"
}

variable "nginx_container_name" {
  type        = string
  default     = "nginx-demo"
  description = "Container name for nginx"
}

