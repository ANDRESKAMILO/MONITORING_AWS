# Datadog
variable "datadog_api_key" {
  type      = string
  sensitive = true
}

variable "datadog_app_key" {
  type      = string
  sensitive = true
}

variable "datadog_site" {
  type    = string
  default = "datadoghq.com"
}

# AWS
variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "external_id" {
  type      = string
  sensitive = true
}

provider "aws" {
  region = var.aws_region
  # No es necesario especificar access_key y secret_key si usas el archivo de credenciales
} 