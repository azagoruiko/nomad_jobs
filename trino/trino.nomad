job "trino" {
  datacenters = ["home"]
  type = "service"
  constraint {
    attribute = "${node.class}"
    value = "guestworker"
  }

  group "trino" {
    count = 1
    network {
      port "http" {
        static = 8080
      }
    }

    task "trino" {
      driver = "docker"

      config {
        image = "trinodb/trino:latest"
        ports = ["http"]
        volumes = [
          "local/trino/catalog:/etc/trino/catalog",
          "local/trino/conf:/etc/trino/conf"
        ]
      }

      template {
        destination = "local/trino/catalog/hive.properties"
        data = <<EOF
{{ range service "hive-metastore" }}
connector.name=hive
fs.native-s3.enabled=true

s3.aws-access-key={{ key "expenses/object/storage/fs.s3a.access.key" }}
s3.aws-secret-key={{ key "expenses/object/storage/fs.s3a.secret.key" }}
s3.endpoint={{ key "expenses/object/storage/fs.s3a.endpoint" }}
s3.region=us-ashburn-1
s3.path-style-access=true
hive.metastore.uri=thrift://{{ .Address }}:{{ .Port }}
{{ end }}

EOF
      }

      template {
        destination = "local/trino/catalog/kindle.properties"
        data = <<EOF
{{ range service "hive-metastore" }}
connector.name=hive
fs.native-s3.enabled=true

s3.aws-access-key={{ key "consulting/object/storage/fs.s3a.access.key" }}
s3.aws-secret-key={{ key "consulting/object/storage/fs.s3a.secret.key" }}
s3.endpoint={{ key "consulting/object/storage/fs.s3a.endpoint" }}
s3.region=us-east-1
s3.path-style-access=true
hive.metastore.uri=thrift://{{ .Address }}:{{ .Port }}
{{ end }}

EOF
      }

      template {
        destination = "local/trino/conf/s3.properties"
        data = <<EOF

EOF
      }

      resources {
        cpu    = 1000
        memory = 5120
      }

      service {
        name = "trino"
        port = "http"

        check {
          type     = "http"
          path     = "/v1/info"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
