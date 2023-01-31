job "minio-job" {
  datacenters = ["home"]
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value = "storage"
  }

  group "minio" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "minio" {
      driver = "docker"

      env {
        MINIO_ACCESS_KEY = "admin"
        MINIO_SECRET_KEY = "password"
      }
      
      config {
        image = "minio/minio:RELEASE.2020-03-25T07-03-04Z"
        args = [
          "server", "/data/minio"
        ]

        port_map {
          web = 9000
        }

        volumes = [
          "/var/nfs/:/data/",
        ]
      }

      resources {
        cpu    = 1100
        memory = 400

        network {
          port  "web" {
            static = 9000
          }
        }
      }

      service {
        name = "minio"
        port = "web"
        tags = ["urlprefix-/minio"]

        check {
          type     = "http"
          path     = "/minio/health/live"
          interval = "10s"
          timeout  = "10s"
        }
      }
    }
  }
}

