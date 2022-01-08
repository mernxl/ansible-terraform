variable "env" {
  type        = string
  description = "Deployment environment name"
}

variable "nginx_container_name" {
  type        = string
  default     = "nginx-demo"
  description = "Container name for nginx"
}

module "terraform" {
  source = "../../terraform"

  env = var.env
  nginx_container_name = var.nginx_container_name
}
