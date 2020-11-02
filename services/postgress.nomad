job "postgres-server" {
  datacenters = ["home"]
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value = "server"
  }

  group "postgres-server" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    ephemeral_disk {
      migrate = true
      size    = 300
      sticky  = true
    }

    task "postgres-server" {
      driver = "docker"

      env {
        PGDATA = "/var/lib/postgresql/data"
        POSTGRES_PASSWORD = "zasada"
      }

      config {
        image = "postgres:12"

        port_map {
          db = 5432
        }

        volumes = [
          "/var/nfs/postgres/data:/var/lib/postgresql/data",
        ]
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          mbits = 100

          port "db" {
            static = 5432
          }
        }
      }

      service {
        name = "postgres-server"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

