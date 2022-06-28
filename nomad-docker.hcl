variable "image" {}
variable "tag" {}
variable "ecr_token" {}

job "demo-docker" {
  datacenters = ["dc1"]

  type = "service"

  group "docker-process" {
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
      driver = "docker"
      resources {
        cpu    = 200
        memory = 512
      }
      env {
        DYNAMIC_PROPERTIES_PATH = "/secrets/dynamic.properties"
      }
      template {
        data = <<EOH
{{- with secret "aws/creds/s3" -}}
aws_access_key={{ .Data.access_key | toJSON }}
aws_secret_key={{ .Data.secret_key | toJSON }}
{{- end }}
      EOH
				env = true
				destination = "secrets/dynamic.properties"
				change_mode = "noop"
      }
      config {
        image = "${var.image}:${var.tag}"
        auth_soft_fail = true
        auth {
          username = "AWS"
          password = var.ecr_token
        }
      }
      logs {
        max_files     = 10
        max_file_size = 10
      }
    }

    update {
      max_parallel     = 1
      min_healthy_time = "10s"
      healthy_deadline = "5m"
    }
  }
}
