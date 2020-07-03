job "attribute-matcher" {
  datacenters = ["home"]
  type        = "service"

  group "attribute-matcher-group" {
    count = 2

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

    task "attribute-matcher-task" {
      driver = "docker"

      config {
        image = "127.0.0.1:9999/docker/attribute-matcher:0.0.2"
        
        port_map {
          web = 8080
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 300
        memory = 1024

        network {
          mbits = 1
          port "web" {}
        }
      }

      service {
        name = "attribute-matcher"
        port = "web"
        tags = ["urlprefix-/matcher strip=/matcher", "urlprefix-/"]

        check {
          type     = "http"
          path     = "/actuator/health"
          interval = "10s"
          timeout  = "10s"
        }
      }
    }
  }
}
