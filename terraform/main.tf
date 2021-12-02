resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "${var.nginx_container_name}--${var.env}"

  ports {
    internal = 80
    external = 80
  }
}
