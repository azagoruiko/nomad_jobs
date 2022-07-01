job "docker-registry-job" {
  datacenters = ["home"]
  type        = "service"
  constraint {
    attribute = "${node.class}"
    value     = "storage"
  }
  group "docker-registry" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "docker_registry" {
      driver = "docker"

      env {
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/nfs/docker"
      }

      config {
        image = "registry"

        port_map {
          web = 5000
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 100
        memory = 256

        network {
          port  "web" {
            static = 5000
          }
        }
      }

      service {
        name = "docker-registry"
        port = "web"
        tags = ["urlprefix-/v2"]

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
