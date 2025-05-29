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
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

provider "aws" {
  region = var.aws_region
}

resource "datadog_dashboard" "dashboard_kai" {
  title        = "Dashboard KAI - Infra AWS"
  description  = "Monitoreo automático de EC2 y S3"
  layout_type  = "ordered"
  is_read_only = false

  widget {
    layout {
      x      = 0
      y      = 0
      width  = 47
      height = 15
    }
    timeseries_definition {
      title       = "EC2 CPU usage (Average)"
      show_legend = true

      request {
        q            = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
        display_type = "line"
      }
    }
  }
} 