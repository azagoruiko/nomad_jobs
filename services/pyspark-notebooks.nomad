job "notebooks-job2" {
  datacenters = ["home"]
  type        = "service"

  constraint {
    attribute = "${node.class}"
    value = "guestworker"
  }

  group "notebooks-group2" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    network {
      port "web" {
        static = 8888
      }
    }

    task "notebooks-task2" {
      driver = "docker"
      template {
        data = <<EOH
POSTGRES_JDBC_URL="{{ key "postgres.jdbc.url" }}"
POSTGRES_JDBC_DRIVER="{{ key "postgres.jdbc.driver" }}"
POSTGRES_JDBC_USER="{{ key "postgres.jdbc.user" }}"
POSTGRES_JDBC_PASSWORD="{{ key "postgres.jdbc.password" }}"

JDBC_URL="{{ key "jdbc.url" }}"
JDBC_DRIVER="{{ key "jdbc.driver" }}"
JDBC_USER="{{ key "jdbc.user" }}"
JDBC_PASSWORD="{{ key "jdbc.password" }}"

CON_JDBC_URL="{{ key "con.jdbc.url" }}"
CON_JDBC_DRIVER="{{ key "con.jdbc.driver" }}"
CON_JDBC_USER="{{ key "con.jdbc.user" }}"
CON_JDBC_PASSWORD="{{ key "con.jdbc.password" }}"

POSTGRES_METASTORE_JDBC_URL="{{ key "hive.postgres.metastore.jdbc.url" }}"
POSTGRES_JDBC_URL="{{ key "postgres.jdbc.url" }}"
POSTGRES_JDBC_DRIVER="{{ key "postgres.jdbc.driver" }}"
POSTGRES_JDBC_USER="{{ key "postgres.jdbc.user" }}"
POSTGRES_JDBC_PASSWORD="{{ key "postgres.jdbc.password" }}"

S3_ENDPOINT="{{ key "expenses/object/storage/fs.s3a.endpoint" }}"
S3_ACCESS_KEY="{{ key "expenses/object/storage/fs.s3a.access.key" }}"
S3_SECRET_KEY="{{ key "expenses/object/storage/fs.s3a.secret.key" }}"
S3_SHARED_BUCKET="{{ key "expenses/object/storage/shared_bucket" }}"

S3_CON_ENDPOINT="{{ key "consulting/object/storage/fs.s3a.endpoint" }}"
S3_CON_ACCESS_KEY="{{ key "consulting/object/storage/fs.s3a.access.key" }}"
S3_CON_SECRET_KEY="{{ key "consulting/object/storage/fs.s3a.secret.key" }}"
S3_CON_SHARED_BUCKET="{{ key "consulting/object/storage/shared_bucket" }}"

SERVICE_MATCHER_BASE_URL="{{ key "expenses/service/matcher/base_url" }}"
SERVICE_GOALS_BASE_URL="{{ key "telegram/bot/accounter/goals.base.url" }}"
SERVICE_SPREADSHEETS_BASE_URL="{{ key "expenses/google/base_url" }}"

{{ range service "spark-master" }}
SPARK_MASTER={{ .Address }}:7077

{{ end }}
EOH
        destination = "secrets.env"
        env = true
      }
      config {
        image = "10.8.0.5:5000/pyspark-notebooks:0.0.5"
        args = [
          "start-notebook.sh",
          "--NotebookApp.token=''",
        ]

        ports = [ "web" ]
        port_map {
          web = 8888
        }
      }

      resources {
        cpu    = 1500
        memory = 5000
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

