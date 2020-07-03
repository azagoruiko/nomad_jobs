job "libpoc" {
  datacenters = ["home"]
  type        = "service"

  group "libpoc-group" {
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

    task "libpoc-task" {
      driver = "docker"

      config {
        image = "127.0.0.1:9999/docker/tomcat-libpoc:0.0.1"
        
        port_map {
          web = 8080
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 100
        memory = 1024

        network {
          mbits = 1
          port "web" {}
        }
      }

      service {
        name = "libpoc"
        port = "web"
        tags = ["urlprefix-/libpoc strip=/libpoc", "urlprefix-/"]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "10s"
        }
      }
    }
  }
}
