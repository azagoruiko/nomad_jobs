job "attribute-matcher" {
  datacenters = ["home"]
  type        = "service"
  
  constraint {
    attribute = "${node.class}"
    value = "guestworker"
  }

  group "attribute-matcher-group" {
    count = 1

    constraint {
      #operator = "distinct_hosts"
      #value = "true"
      
      attribute = "${node.class}"
      value = "guestworker"
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
      }

      resources {
        cpu    = 300
        memory = 512
     
        network {
          port "web" {
            static = 8080
          }
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
