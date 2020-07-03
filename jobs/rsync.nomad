job "rsync" {
  datacenters = ["home"]
  type        = "batch"

  periodic {
    cron      = "*/5 * * * * *"
    prohibit_overlap = true
  }

  group "rsync-group" {
    count = 1


    task "rsync-task" {
      driver = "docker"

      config {
        privileged = true
        image = "127.0.0.1:9999/docker/backuper"

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 100
        memory = 1024

        network {
          mbits = 1
        }
      }
    }
  }
}
