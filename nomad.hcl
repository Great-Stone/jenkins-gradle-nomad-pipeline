variable "version" {
  default = "0"
}

job "demo-java" {
  datacenters = ["dc1"]

  type = "service"

  group "java-process" {
    count = 1

    scaling {
      enabled = true
      min = 1
      max = 3
    }

    network {
      port "http" {}
    }

    vault {
      namespace = ""
      policies = ["aws_policy"]
      change_mode = "noop"
    }

    task "demo" {
      driver = "java"
      resources {
        cpu    = 200
        memory = 512
      }
      env {
        DYNAMIC_PROPERTIES_PATH = "local/dynamic.properties"
      }
      template {
        data = <<EOH
{{- with secret "aws/creds/s3" -}}
aws_access_key={{ .Data.access_key | toJSON }}
aws_secret_key={{ .Data.secret_key | toJSON }}
{{- end }}
      EOH
				env = true
				destination = "local/dynamic.properties"
				change_mode = "noop"
      }
      config {
        jar_path    = "local/file"
        jvm_options = ["-Xms256m", "-Xmx512m"]
      }
      logs {
        max_files     = 10
        max_file_size = 10
      }
      artifact {
        source = "http://localhost:3000/file?file=demo-${var.version}.jar"
        destination = "local"
      }
    }

    update {
      max_parallel     = 1
      min_healthy_time = "10s"
      healthy_deadline = "5m"
    }
  }
}
