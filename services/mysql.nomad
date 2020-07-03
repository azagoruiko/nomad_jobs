job "mysql-server" {
  datacenters = ["home"]
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value = "server"
  }

  group "mysql-server" {
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

    task "mysql-server" {
      driver = "docker"

      env {
        "MYSQL_ALLOW_EMPTY_PASSWORD" = "yes"
        "MYSQL_ROOT_PASSWORD" = "zasada"
      }

      template {
        data = <<EOH
CREATE USER 'sysop'@'%' IDENTIFIED BY 'zasada';
GRANT ALL PRIVILEGES ON *.* TO 'sysop'@'%';
create database expenses;
create table expenses.transactions ( id int primary key auto_increment, transaction_date datetime, category varchar(200), category_id int, amount decimal(13, 2), amount_orig varchar(20), operation varchar(1024), tags varchar(2048));

EOH

        destination = "/docker-entrypoint-initdb.d/db.sql"
      }

      config {
        image = "mysql/mysql-server:8.0"

        port_map {
          db = 3306
        }

        volumes = [
          "/var/lib/mysql/:/var/nfs/mysql/",
          "docker-entrypoint-initdb.d/:/docker-entrypoint-initdb.d/",
        ]
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          mbits = 100

          port "db" {
            static = 3306
          }
        }
      }

      service {
        name = "mysql-server"
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

