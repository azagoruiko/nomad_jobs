job "loadbalancer" {
  datacenters = ["home"]
  type        = "system"

  group "loadbalancer" {

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "fabio" {
      driver = "docker"

      env {
        FABIO_registry_consul_addr = "127.0.0.1:8500"
      }

      config {
        network_mode = "host"
        image = "fabiolb/fabio"

        port_map {
          web = 9999
        }
      }

      resources {
        cpu    = 200
        memory = 256

        network {
          port  "web" {
            static = 9999
          }
        }
      }

      service {
        name = "fabio"
        port = "web"

        #check {
        #  type     = "http"
        #  path     = "/dbwebapp"
        #  interval = "10s"
        #  timeout  = "2s"
        #}
      }
    }
  }
}

