terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.33.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configuración del proveedor Datadog
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

# Configuración del proveedor AWS
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Dashboard de Datadog para monitoreo de AWS
resource "datadog_dashboard" "dashboard_kai" {
  title            = "Dashboard KAI - Infra AWS"
  description      = "Monitoreo automático de EC2 y S3"
  layout_type      = "ordered"
  restricted_roles = []

  widget {
    note_definition {
      content          = "#  мониторинг KAI Dashboard\n\nEste dashboard proporciona una visión general de la infraestructura AWS gestionada."
      background_color = "white"
      font_size        = "16"
      text_align       = "left"
      show_tick        = true
      tick_edge        = "left"
      tick_pos         = "50%"    
    }
  }

  widget {
    timeseries_definition {
      title       = "EC2 CPU usage (Average)"
      show_legend = true

      request {
        q            = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title       = "EC2 CPU Credit Balance (Average)"
      show_legend = true
      request {
        q            = "avg:aws.ec2.cpucredit_balance{*} by {instance_id}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title       = "EC2 Disk Read/Write Ops (Sum)"
      show_legend = true
      request {
        q            = "sum:aws.ec2.disk_read_ops{*} by {instance_id}.as_count()"
        display_type = "bars"
      }
      request {
        q            = "sum:aws.ec2.disk_write_ops{*} by {instance_id}.as_count()"
        display_type = "bars"
      }
    }
  }

  widget {
    timeseries_definition {
      title       = "EC2 Network In/Out (Sum)"
      show_legend = true
      request {
        q            = "sum:aws.ec2.network_in{*} by {instance_id}.as_rate()"
        display_type = "line"
      }
      request {
        q            = "sum:aws.ec2.network_out{*} by {instance_id}.as_rate()"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title       = "S3 Bucket Size (Bytes)"
      show_legend = true
      request {
        q            = "avg:aws.s3.bucket_size_bytes{bucket_name:${aws_s3_bucket.example.bucket}} by {bucket_name}"
        display_type = "area"
      }
    }
  }

  widget {
    query_value_definition {
      title           = "S3 Number of Objects"
      precision       = 0
      live_span       = "5m"
      custom_unit     = "object"
      request {
        q = "max:aws.s3.number_of_objects{bucket_name:${aws_s3_bucket.example.bucket}}.as_count()"
      }
    }
  }

  widget {
    timeseries_definition {
      title       = "S3 Client Errors (4xx Sum)"
      show_legend = true
      request {
        q            = "sum:aws.s3.4xx_errors{bucket_name:${aws_s3_bucket.example.bucket}} by {bucket_name}.as_count()"
        display_type = "bars"
      }
    }
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Bucket S3 de ejemplo
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-acbg-may25-${var.aws_region}-${random_string.bucket_suffix.result}"

  tags = {
    Environment = "Development"
    Project     = "Monitoring AWS"
  }
}

# Instancia EC2 de ejemplo para generar métricas
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example_ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro" # Elegible para la capa gratuita

  tags = {
    Name        = "Example-EC2-KAI"
    Environment = "Development"
    Project     = "Monitoring AWS"
  }
} 