variable "nginx_container_name" {
  type        = string
  default     = "nginx"
  description = "Container name for nginx"
}

module "terraform" {
  source = "../../terraform"

  env = "prod"
  nginx_container_name = var.nginx_container_name
}
