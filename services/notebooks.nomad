job "notebooks-job" {
  datacenters = ["home"]
  type        = "service"

  group "notebooks" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "notebooks" {
      driver = "docker"

      config {
        image = "jupyter/all-spark-notebook"
        args = [
          "start-notebook.sh", "--notebook-dir=/var/nfs/notebooks",
          "--NotebookApp.token=''",
        ]

        port_map {
          web = 8888
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 600
        memory = 1024

        network {
          port  "web" {}
        }
      }

      service {
        name = "notebooks-service"
        port = "web"
        tags = ["urlprefix-/notebooks",
          "urlprefix-/tree",
          "urlprefix-/static",
          "urlprefix-/custom",
          "urlprefix-/api",
          "urlprefix-/nbextensions",
          "urlprefix-/widgets",
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

