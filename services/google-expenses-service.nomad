job "google-expenses-service-job" {
  datacenters = ["home"]
  type        = "service"

  group "docker-registry" {
    count = 2

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "google-expenses-service" {
      driver = "docker"

      config {
        image = "127.0.0.1:9999/docker/google-expenses-import-service"

        port_map {
          web = 8080
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          mbits = 1
          port = "web"
        }
      }

      service {
        name = "google-expenses-service"
        port = "web"
        tags = ["urlprefix-/expenses strip=/expenses"]

        check {
          type     = "http"
          path     = "/v2/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}