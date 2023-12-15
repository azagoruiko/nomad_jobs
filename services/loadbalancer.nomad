job "loadbalancer" {
  datacenters = ["home"]
  type        = "system"

  constraint {
    attribute = "${attr.cpu.arch}"
    value = "amd64"
  }

  group "loadbalancer" {

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    network {
      port "web" {
        static = 9999
      }
    }
    task "fabio" {
      driver = "docker"

      env {
        FABIO_registry_consul_addr = "127.0.0.1:8500"
      }

      config {
        network_mode = "host"
        image = "10.8.0.5:5000/fabio:1"
        ports = ["web"]
      }

      resources {
        cpu    = 200
        memory = 256
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

