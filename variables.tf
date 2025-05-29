# Variables de Datadog
variable "datadog_api_key" {
  description = "API Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "APP Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Sitio de Datadog (ejemplo: datadoghq.com)"
  type        = string
  default     = "datadoghq.com"
}

# Variables de AWS
variable "aws_region" {
  description = "Región principal de AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "Access Key de AWS"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret Key de AWS"
  type        = string
  sensitive   = true
}

# Variables adicionales para EC2 (si se necesitan en el futuro)
variable "ec2_ssh_private_key" {
  description = "Llave privada SSH para EC2"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ec2_user" {
  description = "Usuario SSH para EC2"
  type        = string
  default     = "ec2-user"
}

variable "external_id" {
  description = "External ID for Datadog integration"
  type        = string
  default     = "default-external-id"
} 