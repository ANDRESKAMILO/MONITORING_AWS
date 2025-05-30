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

# Bucket S3 de ejemplo
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-acbg-may25-${var.aws_region}"

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