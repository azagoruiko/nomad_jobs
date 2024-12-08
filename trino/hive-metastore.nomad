job "hive-metastore" {
  datacenters = ["home"]
  type = "service"
  constraint {
    attribute = "${node.class}"
    value = "guestworker"
  }
  group "hive" {
    count = 1
    network {
      port "metastore" {
        static = 9083
        to = 9083
      }
    }
    task "metastore" {
      driver = "docker"
      template {
        data = <<EOH
DATABASE_HOST="{{ key "postgres.host" }}"
DATABASE_USER="{{ key "postgres.jdbc.user" }}"
DATABASE_PASSWORD="{{ key "postgres.jdbc.password" }}"
HIVE_METASTORE_DB_TYPE   = "postgres"
HIVE_METASTORE_DB_PORT   = "5432"
DATABASE_DB   = "new_metastore"
HIVE_METASTORE_URI       = "thrift://localhost:9083"
HIVE_METASTORE_WAREHOUSE = "/user/hive/warehouse"

S3_ENDPOINT_URL="{{ key "expenses/object/storage/fs.s3a.endpoint" }}"
AWS_ACCESS_KEY_ID="{{ key "expenses/object/storage/fs.s3a.access.key" }}"
AWS_SECRET_ACCESS_KEY="{{ key "expenses/object/storage/fs.s3a.secret.key" }}"
S3_BUCKET="metastore"
S3_PREFIX="data"

EOH
        destination = "secrets.env"
        env = true
      }
      config {
        image = "naushadh/hive-metastore"
        ports = ["metastore"]

        command = "sh"
        args = [
          "-c",
          "ln -s /opt/hadoop/etc/hadoop/core-site.xml /opt/hive-metastore/conf/core-site.xml && ln -s /opt/hadoop/share/hadoop/common/lib/aws-java-sdk* /opt/hive-metastore/lib/ && ln -s /opt/hadoop/share/hadoop/common/lib/hadoop-aws* /opt/hive-metastore/lib/ && ./run.sh"
        ]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "hive-metastore"
        port = "metastore"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
