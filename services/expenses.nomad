job "google-expenses-service-job" {
  datacenters = ["home"]
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value = "guestworker"
  }

  group "google-expenses" {
    count = 1

    constraint {
      operator = "distinct_hosts"
      value = "true"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "google-expenses-service" {
      driver = "docker"

      config {
        image = "127.0.0.1:9999/docker/google-expenses-import-service:0.0.5"
        
        port_map {
          web = 8080
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 100
        memory = 512

        network {
          port "web" {}
        }
      }

      service {
        name = "google-expenses-service"
        port = "web"
        tags = ["urlprefix-/expenses strip=/expenses"]

        check {
          type     = "http"
          path     = "/health/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
