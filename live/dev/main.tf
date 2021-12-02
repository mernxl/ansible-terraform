variable "nginx_container_name" {
  type        = string
  default     = "nginx-demo"
  description = "Container name for nginx"
}

module "terraform" {
  source = "../../terraform"

  env = "dev"
  nginx_container_name = var.nginx_container_name
}
