# 📊 Curso: Monitoreo con Datadog usando Terraform + GitHub Actions + AWS

> **"Automatiza, despliega y monitorea tu infraestructura de forma reproducible y segura."**

---

## 🔖 Índice

- [📊 Curso: Monitoreo con Datadog usando Terraform + GitHub Actions + AWS](#-curso-monitoreo-con-datadog-usando-terraform--github-actions--aws)
  - [🔖 Índice](#-índice)
  - [Motivación](#motivación)
  - [Objetivos del Curso](#objetivos-del-curso)
  - [Prerequisitos](#prerequisitos)
  - [Estructura del Repositorio](#estructura-del-repositorio)
  - [1. Configuración de AWS e IAM](#1-configuración-de-aws-e-iam)
    - [1.1. Crear un Usuario IAM para Terraform](#11-crear-un-usuario-iam-para-terraform)
    - [1.2. Generar Claves de Acceso para el Usuario de Terraform](#12-generar-claves-de-acceso-para-el-usuario-de-terraform)
    - [1.3. (Opcional Anterior) Configuración de `~/.aws/credentials`](#13-opcional-anterior-configuración-de-awscredentials)
  - [2. Configuración de Datadog](#2-configuración-de-datadog)
    - [2.1. Obtener la API Key de Datadog](#21-obtener-la-api-key-de-datadog)
    - [2.2. Obtener la Application Key de Datadog](#22-obtener-la-application-key-de-datadog)
    - [2.3. Identificar tu Sitio Datadog (`datadog_site`)](#23-identificar-tu-sitio-datadog-datadog_site)
    - [2.4. Configurar la Integración de AWS en Datadog (Requisito Previo)](#24-configurar-la-integración-de-aws-en-datadog-requisito-previo)
  - [3. Archivos de Terraform](#3-archivos-de-terraform)
    - [3.1. `main.tf`](#31-maintf)
    - [3.2. `variables.tf`](#32-variablestf)
    - [3.3. `outputs.tf`](#33-outputstf)
    - [3.4. `.gitignore`](#34-gitignore)
    - [3.5. `secrets.auto.tfvars.json` (Ejemplo Local - NO SUBIR A GIT)](#35-secretsautotfvarsjson-ejemplo-local---no-subir-a-git)
  - [4. Configuración de GitHub Actions](#4-configuración-de-github-actions)
    - [4.1. `.github/workflows/deploy.yml`](#41-githubworkflowsdeployyml)
  - [5. Puesta en Práctica Paso a Paso](#5-puesta-en-práctica-paso-a-paso)
    - [5.1. Clonar y Preparar el Repositorio (Si Aún No lo Has Hecho)](#51-clonar-y-preparar-el-repositorio-si-aún-no-lo-has-hecho)
    - [5.2. Configurar Credenciales Locales (`secrets.auto.tfvars.json`)](#52-configurar-credenciales-locales-secretsautotfvarsjson)
    - [5.3. Configurar Secretos en GitHub Actions](#53-configurar-secretos-en-github-actions)
    - [5.4. Inicializar Terraform Localmente](#54-inicializar-terraform-localmente)
    - [5.5. Planificar y Aplicar Localmente (Opcional, para Pruebas)](#55-planificar-y-aplicar-localmente-opcional-para-pruebas)
    - [5.6. Hacer Push a GitHub para Desplegar con GitHub Actions](#56-hacer-push-a-github-para-desplegar-con-github-actions)
  - [6. Validación en Datadog y AWS](#6-validación-en-datadog-y-aws)
  - [7. Consideraciones Adicionales y Próximos Pasos](#7-consideraciones-adicionales-y-próximos-pasos)
  - [8. Troubleshooting / Solución de Problemas Comunes](#8-troubleshooting--solución-de-problemas-comunes)
  - [9. Conclusión (Anteriormente Sección 8)](#9-conclusión-anteriormente-sección-8)
  - [10. Recursos y Referencias (Anteriormente Sección 9)](#10-recursos-y-referencias-anteriormente-sección-9)
  - [✅ ¿Este flujo dejará GitHub Actions completamente funcional?](#-este-flujo-dejará-github-actions-completamente-funcional)

---

## Motivación

En entornos de producción o preproducción, contar con un sistema de monitoreo fiable es esencial para detectar problemas de rendimiento, cargas de CPU altas, errores en logs o saturación de recursos. Con este curso aprenderás a:

- **Automatizar** la creación de un _Dashboard_ en Datadog que monitoree instancias EC2 y buckets S3 de AWS.  
- **Provisionar** roles y políticas de AWS de forma declarativa usando Terraform.  
- **Integrar** todo el flujo en un pipeline de CI/CD con GitHub Actions, garantizando despliegues consistentes.  
- **Implementar** buenas prácticas de seguridad (manejo de secretos, control de acceso, trazabilidad).  

---

## Objetivos del Curso

1. Conocer cómo configurar credenciales y roles en AWS (IAM) para que Terraform pueda operar.  
2. Aprender a crear un proveedor de Datadog en Terraform y a generar un _Dashboard_ inicial.  
3. Desarrollar archivos de Terraform (`main.tf`, `variables.tf`, `outputs.tf`, `.gitignore`) para codificar la infraestructura.  
4. Configurar un workflow de GitHub Actions que ejecute `terraform init`, `plan` y `apply` automáticamente.  
5. Verificar en Datadog que los recursos creados se reflejen en métricas y gráficos.  
6. Entender los pasos clave para mantener el pipeline seguro y reproducible.  

---

## Prerequisitos

- Cuenta activa en **AWS** (Con permisos de IAM para crear roles, políticas y recursos como EC2/S3).  
- Cuenta activa en **Datadog** (con API Key y Application Key ya generadas).  
- Terraform instalado localmente (versión recomendada: `>= 1.4.0`).  
- Conocimientos básicos de **Terraform** (bloques `provider`, `resource`, `variable`, `output`).  
- Repositorio GitHub donde guardar el proyecto; permisos para configurar **GitHub Actions**.  
- VS Code o editor de texto preferido.  

---

## Estructura del Repositorio

```plaintext
terraform-monitoring/
├── main.tf                        # Definición principal de proveedores y recursos
├── variables.tf                   # Variables sensibles y no sensibles
├── outputs.tf                     # Salidas útiles (URLs, IDs, etc.)
├── .gitignore                     # Regla para ignorar archivos locales
├── secrets.auto.tfvars.json       # (NO subir) Contiene secretos localmente
├── README.md                      # Este documento
├── docs/                          # Documentación del proyecto
│   └── Curso_1.md                 # Curso de monitoreo
└── .github/
    └── workflows/
        └── deploy.yml             # Pipeline de GitHub Actions
```
> Los archivos `*.auto.tfvars.json` se cargan automáticamente en Terraform, pero NUNCA deben subirse a GitHub.


---

## 1. Configuración de AWS e IAM

Para que Terraform pueda interactuar con tu cuenta de AWS y gestionar recursos (como instancias EC2, buckets S3, roles para Datadog, etc.), necesitamos configurar un usuario IAM con los permisos adecuados y obtener sus credenciales de acceso.

**Práctica Recomendada: No usar el Usuario Raíz**

Es crucial **NUNCA** usar las credenciales del usuario raíz de tu cuenta de AWS para tareas automatizadas o acceso programático. El usuario raíz tiene control total y sus credenciales deben guardarse de forma segura y usarse solo para tareas muy específicas de gestión de la cuenta.

En su lugar, crearemos un usuario IAM dedicado exclusivamente para Terraform.

### 1.1. Crear un Usuario IAM para Terraform

1.  **Ingresa a la Consola de AWS y ve a IAM:**
    *   Ve a [https://aws.amazon.com/console/](https://aws.amazon.com/console/) e inicia sesión.
    *   En la barra de búsqueda de servicios (arriba), escribe `IAM` y selecciónalo.
2.  **Ve a "Usuarios":**
    *   En el menú de navegación de la izquierda, haz clic en **"Usuarios"** (debajo de "Administración del acceso").
3.  **Crea un Nuevo Usuario:**
    *   Haz clic en el botón **"Crear usuario"**.
4.  **Nombre de Usuario:**
    *   Dale un nombre descriptivo, por ejemplo: `terraform-provisioner`.
    *   **NO** selecciones "Proporcionar acceso de usuario a la Consola de administración de AWS" (a menos que sea necesario por otra razón, para Terraform no lo es).
    *   Haz clic en **"Siguiente"**.
5.  **Establecer Permisos:**
    *   Selecciona **"Asociar políticas existentes directamente"**.
    *   Para este curso, y para asegurar que Terraform tenga suficientes permisos iniciales, adjunta la política administrada por AWS: `AdministratorAccess`.
        *   **Nota de Seguridad:** `AdministratorAccess` otorga control total. En un entorno de producción, deberías crear y adjuntar una política personalizada con los permisos mínimos estrictamente necesarios para las acciones que Terraform realizará.
    *   Busca `AdministratorAccess` en la lista de políticas, marca su casilla y haz clic en **"Siguiente"**.
6.  **Revisar y Crear:**
    *   Revisa el nombre del usuario y los permisos adjuntos.
    *   Haz clic en **"Crear usuario"**.

### 1.2. Generar Claves de Acceso para el Usuario de Terraform

Una vez creado el usuario `terraform-provisioner`, necesitamos generar claves de acceso para que Terraform pueda autenticarse programáticamente.

1.  **Selecciona el Usuario Creado:**
    *   En la lista de usuarios IAM, haz clic en el nombre del usuario `terraform-provisioner`.
2.  **Ve a "Credenciales de seguridad":**
    *   Dentro de la página de detalles del usuario, selecciona la pestaña **"Credenciales de seguridad"**.
3.  **Crea una Clave de Acceso:**
    *   En la sección **"Claves de acceso"**, haz clic en **"Crear clave de acceso"**.
4.  **Caso de Uso:**
    *   Selecciona **"Interfaz de línea de comandos (CLI)"** como el caso de uso. Esto es apropiado para herramientas como Terraform.
    *   Marca la casilla de confirmación: **"Comprendo la recomendación anterior y deseo continuar para crear una clave de acceso."**
    *   Haz clic en **"Siguiente"**.
5.  **Descripción (Opcional):**
    *   Puedes agregar una etiqueta de descripción para la clave (ej. `terraform-automation-key`).
    *   Haz clic en **"Crear clave de acceso"**.
6.  **Guarda las Credenciales de Forma Segura:**
    *   Se mostrarán tu nuevo **`ID de clave de acceso`** (Access Key ID) y tu **`Clave de acceso secreta`** (Secret Access Key).
    *   **¡IMPORTANTE! Esta es la ÚNICA vez que podrás ver y descargar la Clave de Acceso Secreta.**
    *   Copia ambos valores inmediatamente y guárdalos en un lugar muy seguro (preferiblemente un gestor de contraseñas).
    *   También puedes hacer clic en **"Descargar archivo .csv"** para guardar un archivo con estas credenciales.
    *   Haz clic en **"Hecho"**.

    Estas dos claves (`ID de clave de acceso` y `Clave de acceso secreta`) son las que usarás como `aws_access_key` y `aws_secret_key` en tus archivos de variables de Terraform y en los secretos de GitHub Actions.

### 1.3. (Opcional Anterior) Configuración de `~/.aws/credentials`
Si bien para este curso gestionaremos las credenciales mediante `secrets.auto.tfvars.json` (localmente) y secretos de GitHub Actions (para CI/CD), es bueno saber que Terraform también puede leer credenciales del archivo `~/.aws/credentials` (en Windows: `C:\Users\TU_USUARIO\.aws\credentials`). Si optaras por este método, el formato sería:

```ini
[default]
aws_access_key_id     = TU_ID_DE_CLAVE_DE_ACCESO
aws_secret_access_key = TU_CLAVE_DE_ACCESO_SECRETA
```
Sin embargo, para mantener la portabilidad y la claridad en este proyecto, nos enfocaremos en las variables.

---

## 2. Configuración de Datadog

Para que Terraform pueda crear y gestionar recursos en tu cuenta de Datadog (como dashboards o monitores), necesita autenticarse usando una API Key y una Application Key.

### 2.1. Obtener la API Key de Datadog

1.  **Ingresa a Datadog:**
    *   Ve al sitio de tu organización Datadog (ej. `https://app.us5.datadoghq.com` o `https://app.datadoghq.com`) e inicia sesión.
2.  **Navega a "Organization Settings":**
    *   En el menú de navegación de la izquierda (generalmente abajo), pasa el cursor sobre tu nombre de usuario/organización y selecciona **"Organization Settings"**.
3.  **Selecciona "API Keys":**
    *   En el menú de la izquierda de "Organization Settings", haz clic en **"API Keys"**.
    *   Verás una lista de tus API Keys existentes (si las hay).
4.  **Copia una API Key Existente o Crea una Nueva:**
    *   Puedes copiar el valor de una API Key existente (pasando el cursor sobre la clave oculta y haciendo clic en el ícono de copiar) si es apropiada para este proyecto.
    *   Para crear una nueva:
        *   Haz clic en el botón **"+ New Key"** (o similar, el texto puede variar ligeramente).
        *   Dale un nombre descriptivo a tu nueva API Key (ej. `terraform-project-api-key`).
        *   Haz clic en **"Create Key"**.
        *   **Copia inmediatamente la clave generada y guárdala en un lugar seguro.**
    *   Esta clave es la que usarás para la variable `datadog_api_key`.

### 2.2. Obtener la Application Key de Datadog

1.  **Navega a "Application Keys":**
    *   Aún en "Organization Settings", selecciona **"Application Keys"** en el menú de la izquierda.
2.  **Copia una Application Key Existente o Crea una Nueva:**
    *   Puedes usar una Application Key existente si sus permisos (ámbitos/scopes) son adecuados.
    *   Para crear una nueva:
        *   Haz clic en **"+ New Key"** (o similar).
        *   Dale un nombre descriptivo (ej. `terraform-project-app-key`).
        *   **Ámbitos (Scopes):** Es importante que esta clave tenga los permisos necesarios para las acciones que Terraform realizará. Para crear y gestionar dashboards, necesitarás al menos los ámbitos `dashboards_read` y `dashboards_write`. Si no estás seguro, puedes crear una clave sin seleccionar ámbitos específicos (lo que usualmente otorga permisos amplios) o revisar y ajustar los ámbitos de una clave existente. Para este curso, asegurar `dashboards_read` y `dashboards_write` es un buen comienzo.
        *   Haz clic en **"Create Key"**.
        *   **Copia inmediatamente la clave generada y guárdala en un lugar seguro.**
    *   Esta clave es la que usarás para la variable `datadog_app_key`.

### 2.3. Identificar tu Sitio Datadog (`datadog_site`)

La URL que usas para acceder a Datadog determina el valor de `datadog_site` que Terraform necesita para apuntar a la API correcta.

*   Si accedes a Datadog a través de `https://app.datadoghq.com`, tu `datadog_site` es `datadoghq.com`.
*   Si accedes a través de `https://app.us5.datadoghq.com` (como en nuestro caso), tu `datadog_site` es `us5.datadoghq.com`.
*   Otros ejemplos: `datadoghq.eu`, `us3.datadoghq.com`, `ap1.datadoghq.com`.

Este valor es crucial y se usa en la variable `datadog_site`.

### 2.4. Configurar la Integración de AWS en Datadog (Requisito Previo)

Para que Datadog pueda recopilar métricas de tus servicios AWS (como EC2, S3, etc.), la integración de AWS debe estar configurada en Datadog. Esto implica:

1.  **Crear un Rol IAM en AWS** (ej. `DatadogIntegrationRole`) con los permisos que Datadog necesita (Datadog proporciona políticas gestionadas para esto, como `DatadogAWSIntegrationPolicy`).
2.  Establecer una **Relación de Confianza** en ese rol que permita a la cuenta de AWS de Datadog (usualmente `arn:aws:iam::464622532012:root`) asumir el rol, utilizando un **External ID** para mayor seguridad.
3.  **Configurar la Integración en Datadog:** En Datadog (Integrations -> AWS), agregar tu cuenta de AWS especificando el ID de tu cuenta y el nombre del rol creado. Datadog te proporcionará el External ID que debes usar en la política de confianza del rol.

**Nota:** Este curso asume que esta integración base AWS-Datadog ya está configurada o se configurará manualmente. El `main.tf` que desarrollamos no crea este rol de integración inicial, pero sí el dashboard que consume sus datos. El `external_id` en nuestras variables de Terraform se refiere al External ID de esta integración, y sería relevante si Terraform estuviera gestionando el `DatadogIntegrationRole`.

---

## 3. Archivos de Terraform

A continuación, se detalla la configuración de los principales archivos de Terraform que usaremos.

### 3.1. `main.tf`

Este archivo es el corazón de nuestra configuración de Terraform. Define los proveedores (AWS y Datadog), los recursos a crear (bucket S3, instancia EC2, dashboard de Datadog), y cómo se conectan entre sí.

```hcl
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.33.0" // Puedes ajustar la versión según sea necesario
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"    // Puedes ajustar la versión según sea necesario
    }
    // Proveedor random para generar nombres únicos si se desea
    // random = {
    //   source  = "hashicorp/random"
    //   version = "~> 3.1"
    // }
  }
}

# Configuración del proveedor Datadog
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/" // Construye la URL de la API dinámicamente
}

# Configuración del proveedor AWS
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key // Credenciales del usuario IAM terraform-provisioner
  secret_key = var.aws_secret_key // Credenciales del usuario IAM terraform-provisioner
}

# (Opcional) Recurso para generar un sufijo aleatorio para nombres de bucket
# resource "random_id" "bucket_suffix" {
#   byte_length = 4
# }

# Bucket S3 de ejemplo
resource "aws_s3_bucket" "example" {
  # Nombre de bucket único globalmente. Ejemplo:
  # bucket = "example-bucket-iniciales-fecha-${var.aws_region}"
  # bucket = "example-bucket-${random_id.bucket_suffix.hex}-${var.aws_region}" 
  bucket = "example-bucket-acbg-may25-${var.aws_region}" // Asegúrate que este nombre sea único

  tags = {
    Environment = "Development"
    Project     = "Monitoring AWS"
  }
}

# Data source para obtener la AMI más reciente de Amazon Linux 2
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

# Instancia EC2 de ejemplo para generar métricas
resource "aws_instance" "example_ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro" // Elegible para la capa gratuita de AWS

  tags = {
    Name        = "Example-EC2-KAI"
    Environment = "Development"
    Project     = "Monitoring AWS"
  }
  // Para un uso más avanzado, considera añadir:
  // key_name      = "tu-par-de-claves-ssh" 
  // vpc_security_group_ids = ["sg-tuiddegrupodeseguridad"]
  // user_data     = <<-EOF
  //              #!/bin/bash
  //              # Comandos para instalar el agente de Datadog, etc.
  //              EOF
}

# Dashboard de Datadog para monitoreo de AWS
resource "datadog_dashboard" "dashboard_kai" {
  title        = "Dashboard KAI - Infra AWS"
  description  = "Monitoreo automático de EC2 y S3"
  layout_type  = "ordered"
  is_read_only = false
  // restricted_roles = [] // Opcional: restringe quién puede ver/editar

  widget {
    timeseries_definition {
      title       = "EC2 CPU usage (Average)"
      show_legend = true

      request {
        q            = "avg:aws.ec2.cpuutilization{*} by {instance_id}" // Consulta básica de CPU
        display_type = "line"
      }
      // Puedes añadir más requests para otras métricas o visualizaciones
    }
    // layout { // Ajusta la posición y tamaño si es necesario, pero "ordered" lo maneja bien
    //   x      = 0 
    //   y      = 0
    //   width  = 47
    //   height = 15
    // }
  }
  // Puedes añadir más widgets aquí para S3, logs, etc.
}
```

### 3.2. `variables.tf`

Este archivo define las variables que nuestro proyecto utilizará. Separar las definiciones de variables ayuda a mantener el código organizado y facilita la comprensión de qué entradas requiere nuestra configuración.

```hcl
# Variables de Datadog
variable "datadog_api_key" {
  description = "API Key de Datadog"
  type        = string
  sensitive   = true // Marca la variable como sensible para no mostrarla en logs
}

variable "datadog_app_key" {
  description = "APP Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Sitio de Datadog (ej: datadoghq.com, us3.datadoghq.com, us5.datadoghq.com, datadoghq.eu)"
  type        = string
  default     = "us5.datadoghq.com" // Ajusta este default a tu sitio correcto
}

variable "external_id" {
  description = "External ID para la integración de AWS con Datadog (proporcionado por Datadog)"
  type        = string
  sensitive   = true
  // default  = "TU_EXTERNAL_ID" // Descomenta y reemplaza si Terraform gestiona el rol de integración
}

# Variables de AWS
variable "aws_region" {
  description = "Región principal de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1" // Cambia si usas otra región primaria
}

variable "aws_access_key" {
  description = "Access Key del usuario IAM de AWS para Terraform (terraform-provisioner)"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret Key del usuario IAM de AWS para Terraform (terraform-provisioner)"
  type        = string
  sensitive   = true
}

# Variables adicionales para EC2 (pueden expandirse en el futuro)
# variable "ec2_ssh_key_name" {
#   description = "Nombre del par de claves SSH para EC2"
#   type        = string
#   default     = ""
# }

# variable "ec2_user" {
#   description = "Usuario SSH para EC2"
#   type        = string
#   default     = "ec2-user"
# }
```

**Nota sobre `external_id`:** En la configuración actual, `external_id` se declara pero no se usa activamente en `main.tf` porque no estamos creando el rol de integración AWS-Datadog con Terraform. Si en el futuro decides gestionar ese rol con Terraform, esta variable será esencial para la política de confianza del rol.

### 3.3. `outputs.tf`

Este archivo define las salidas que queremos que Terraform muestre después de aplicar la configuración. Son útiles para obtener rápidamente información importante como URLs o IDs.

```hcl
output "dashboard_url" {
  value       = datadog_dashboard.dashboard_kai.url // Muestra la URL directa al dashboard creado
  description = "URL del Dashboard de Datadog creado"
}

output "aws_region_out" {
  value       = var.aws_region
  description = "Región de AWS utilizada para los recursos"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.example.bucket
  description = "Nombre del bucket S3 creado"
}

output "ec2_instance_id" {
  value       = aws_instance.example_ec2.id
  description = "ID de la instancia EC2 creada"
}
```

### 3.4. `.gitignore`

Este archivo especifica los archivos y directorios que Git debe ignorar. Es crucial para evitar subir archivos sensibles o temporales al repositorio.

```gitignore
# Archivos y directorios generados por Terraform
.terraform/
*.tfstate
*.tfstate.backup
terraform.tfvars
.terraform.lock.hcl

# Credenciales locales - ¡NUNCA SUBIR A GIT!
secrets.auto.tfvars.json 
# Si usas terraform.tfvars para secretos, también ignóralo:
# terraform.tfvars

# Archivos temporales de editor y sistema operativo
.vscode/
.DS_Store
Thumbs.db
desktop.ini

# Logs o archivos temporales del proyecto
*.log
*.tmp
*.bak
```

### 3.5. `secrets.auto.tfvars.json` (Ejemplo Local - NO SUBIR A GIT)

Este archivo se utiliza para proporcionar valores a las variables definidas en `variables.tf` de forma local. **Debe estar en tu `.gitignore` para no subirlo al repositorio.**

```json
{
  "datadog_api_key":     "TU_DATADOG_API_KEY_REAL",
  "datadog_app_key":     "TU_DATADOG_APP_KEY_REAL",
  "datadog_site":        "us5.datadoghq.com", // ¡Importante! Usa tu sitio Datadog correcto.
  "external_id":         "TU_DATADOG_EXTERNAL_ID_REAL", // Proporcionado por Datadog para la integración AWS.
  "aws_access_key":      "ID_CLAVE_ACCESO_USUARIO_TERRAFORM_PROVISIONER",
  "aws_secret_key":      "CLAVE_SECRETA_USUARIO_TERRAFORM_PROVISIONER",
  "aws_region":          "us-east-1" // O la región que hayas elegido.
}
```

---

## 4. Configuración de GitHub Actions

El archivo `.github/workflows/deploy.yml` define el pipeline de CI/CD que automatiza la inicialización, validación, planificación y aplicación de nuestra configuración de Terraform cada vez que se hace un push a la rama `main`.

### 4.1. `.github/workflows/deploy.yml`

```yaml
name: Terraform Deploy - Datadog + AWS

on:
  push:
    branches:
      - main # El workflow se dispara en pushes a la rama main
  # Opcional: permitir ejecución manual desde la UI de GitHub Actions
  # workflow_dispatch:

jobs:
  terraform:
    name: Terraform Plan and Apply
    runs-on: ubuntu-latest
    # Opcional: Especificar permisos para el GITHUB_TOKEN si se interactúa con otros servicios de GitHub
    # permissions:
    #   contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: "1.4.0" # Especifica la versión de Terraform que quieres usar

      - name: Terraform Init
        run: terraform init
        # Opcional: Configurar backend si usas S3, Terraform Cloud, etc.
        # env:
        #   AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        #   AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -input=false -no-color # -no-color para logs más limpios
        env:
          # Mapeo de secretos de GitHub a variables de Terraform (prefijo TF_VAR_)
          TF_VAR_datadog_api_key: ${{ secrets.DATADOG_API_KEY }}
          TF_VAR_datadog_app_key: ${{ secrets.DATADOG_APP_KEY }}
          TF_VAR_datadog_site: ${{ secrets.DATADOG_SITE }} # ej. us5.datadoghq.com
          TF_VAR_external_id: ${{ secrets.DATADOG_EXTERNAL_ID }}
          TF_VAR_aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }} # Del usuario terraform-provisioner
          TF_VAR_aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }} # Del usuario terraform-provisioner
          TF_VAR_aws_region: ${{ secrets.AWS_REGION }} # ej. us-east-1
        # Opcional: Si quieres mostrar el plan en el output del Action
        # id: plan 
        # continue-on-error: true # Si quieres que el apply se ejecute incluso si el plan tiene cambios destructivos (¡cuidado!)

      # Opcional: Comentar el plan en un Pull Request (requiere configuración adicional)
      # - name: Comment Plan Output on PR
      #   if: github.event_name == 'pull_request'
      #   uses: actions/github-script@v6
      #   with:
      #     script: |
      #       // Tu script para comentar el plan

      - name: Terraform Apply
        # Solo aplicar en la rama main y si el plan no tuvo errores (si no se usa continue-on-error en el plan)
        if: github.ref == 'refs/heads/main' # && steps.plan.outcome == 'success' 
        run: terraform apply -auto-approve -input=false -no-color
        env:
          TF_VAR_datadog_api_key: ${{ secrets.DATADOG_API_KEY }}
          TF_VAR_datadog_app_key: ${{ secrets.DATADOG_APP_KEY }}
          TF_VAR_datadog_site: ${{ secrets.DATADOG_SITE }}
          TF_VAR_external_id: ${{ secrets.DATADOG_EXTERNAL_ID }}
          TF_VAR_aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          TF_VAR_aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_aws_region: ${{ secrets.AWS_REGION }}
```

**Asegúrate de que los siguientes secretos estén configurados en tu repositorio de GitHub** (Settings → Secrets and variables → Actions):

*   `DATADOG_API_KEY`: Tu API Key de Datadog.
*   `DATADOG_APP_KEY`: Tu Application Key de Datadog.
*   `DATADOG_SITE`: Tu sitio Datadog (ej. `us5.datadoghq.com`).
*   `DATADOG_EXTERNAL_ID`: El External ID de tu integración AWS en Datadog.
*   `AWS_ACCESS_KEY_ID`: El ID de la clave de acceso de tu usuario IAM `terraform-provisioner`.
*   `AWS_SECRET_ACCESS_KEY`: La clave de acceso secreta de tu usuario IAM `terraform-provisioner`.
*   `AWS_REGION`: La región de AWS donde quieres desplegar (ej. `us-east-1`).

---

## 5. Puesta en Práctica Paso a Paso

Ahora que hemos configurado nuestros proveedores, variables y el pipeline de GitHub Actions, sigamos estos pasos para desplegar y verificar nuestra infraestructura de monitoreo.

### 5.1. Clonar y Preparar el Repositorio (Si Aún No lo Has Hecho)

1.  **Clona tu repositorio de GitHub** a tu máquina local:
    ```bash
    git clone https://github.com/TU_USUARIO/TU_REPOSITORIO.git
    cd TU_REPOSITORIO
    ```
    Reemplaza `TU_USUARIO` y `TU_REPOSITORIO` con tus valores correspondientes.

2.  **Verifica la Estructura de Archivos:**
    Asegúrate de tener los archivos principales como `main.tf`, `variables.tf`, `outputs.tf`, `.gitignore`, y el directorio `.github/workflows/deploy.yml`.

### 5.2. Configurar Credenciales Locales (`secrets.auto.tfvars.json`)

Para poder ejecutar Terraform localmente (ej. `terraform plan`, `terraform apply` para pruebas), necesitas proporcionar los valores de tus variables sensibles. Crea un archivo llamado `secrets.auto.tfvars.json` en la raíz de tu proyecto con el siguiente contenido, reemplazando los placeholders con tus valores reales:

```json
{
  "datadog_api_key":     "TU_DATADOG_API_KEY_REAL",
  "datadog_app_key":     "TU_DATADOG_APP_KEY_REAL",
  "datadog_site":        "us5.datadoghq.com", // ¡Importante! Usa tu sitio Datadog correcto.
  "external_id":         "TU_DATADOG_EXTERNAL_ID_REAL", // Proporcionado por Datadog para la integración AWS.
  "aws_access_key":      "ID_CLAVE_ACCESO_USUARIO_TERRAFORM_PROVISIONER",
  "aws_secret_key":      "CLAVE_SECRETA_USUARIO_TERRAFORM_PROVISIONER",
  "aws_region":          "us-east-1" // O la región que hayas elegido.
}
```

**¡MUY IMPORTANTE!**
*   Este archivo `secrets.auto.tfvars.json` **NUNCA debe ser subido a GitHub**. Asegúrate de que esté listado en tu archivo `.gitignore`.
*   Terraform carga automáticamente los archivos que terminan en `.auto.tfvars` o `.auto.tfvars.json`.

### 5.3. Configurar Secretos en GitHub Actions

Para que el pipeline de GitHub Actions pueda desplegar tu infraestructura, debes configurar los mismos valores sensibles como secretos en tu repositorio de GitHub:

1.  Ve a tu repositorio en GitHub.
2.  Haz clic en **"Settings"** (Configuración) -> **"Secrets and variables"** (Secretos y variables) en el menú lateral -> **"Actions"**.
3.  Haz clic en **"New repository secret"** (Nuevo secreto del repositorio) para cada uno de los siguientes secretos, asegurándote de que los nombres coincidan exactamente:
    *   `DATADOG_API_KEY`: Tu API Key de Datadog.
    *   `DATADOG_APP_KEY`: Tu Application Key de Datadog (asegúrate de que tenga los ámbitos necesarios, ej. `dashboards_read`, `dashboards_write`).
    *   `DATADOG_SITE`: Tu sitio Datadog (ej. `us5.datadoghq.com`).
    *   `DATADOG_EXTERNAL_ID`: El External ID de tu integración AWS en Datadog.
    *   `AWS_ACCESS_KEY_ID`: El ID de la clave de acceso de tu usuario IAM `terraform-provisioner`.
    *   `AWS_SECRET_ACCESS_KEY`: La clave de acceso secreta de tu usuario IAM `terraform-provisioner`.
    *   `AWS_REGION`: La región de AWS donde quieres desplegar (ej. `us-east-1`).

### 5.4. Inicializar Terraform Localmente

Antes de ejecutar cualquier comando de Terraform, necesitas inicializar el directorio de trabajo. Este comando descarga los proveedores necesarios.

```bash
terraform init
```
Si has añadido o cambiado versiones de proveedores (como el proveedor `random` si decidiste usarlo), ejecuta `terraform init -upgrade`.

### 5.5. Planificar y Aplicar Localmente (Opcional, para Pruebas)

Puedes verificar tu configuración localmente antes de hacer push a GitHub:

1.  **Planificar:**
    ```bash
    terraform plan
    ```
    Revisa la salida para entender qué recursos Terraform creará, modificará o destruirá. Asegúrate de que no haya errores.

2.  **Aplicar:**
    ```bash
    terraform apply
    ```
    Terraform te pedirá confirmación. Escribe `yes` para proceder. Si quieres auto-aprobar (¡con cuidado!):
    ```bash
    terraform apply -auto-approve
    ```

### 5.6. Hacer Push a GitHub para Desplegar con GitHub Actions

Una vez que estés satisfecho con tu configuración y la hayas probado localmente (opcionalmente):

1.  Asegúrate de que todos tus cambios estén guardados y añadidos a Git:
    ```bash
    git add .
    git commit -m "Configuración inicial de Terraform para monitoreo AWS con Datadog"
    ```
2.  Haz push a la rama `main` (o la rama configurada en tu workflow):
    ```bash
    git push origin main
    ```
3.  **Verifica el Workflow en GitHub Actions:**
    *   Ve a la pestaña **"Actions"** en tu repositorio de GitHub.
    *   Deberías ver tu workflow ejecutándose. Haz clic en él para ver los detalles de cada paso (`init`, `validate`, `plan`, `apply`).
    *   Si todo está configurado correctamente, el workflow debería completarse exitosamente, aplicando tu infraestructura.

---

## 6. Validación en Datadog y AWS

Una vez que Terraform haya aplicado la configuración (ya sea localmente o mediante GitHub Actions), es hora de verificar que los recursos se hayan creado y que el monitoreo comience a funcionar.

1.  **Verificar Recursos en AWS:**
    *   **Instancia EC2:**
        *   Ve a la consola de AWS -> EC2 -> Instancias.
        *   Busca la instancia con la etiqueta `Name` igual a `Example-EC2-KAI` (o el nombre que le hayas dado).
        *   Confirma que esté en estado "ejecutándose" (running) y que las comprobaciones de estado estén pasando (ej. "2/2 comprobaciones superadas").
        *   *(Referencia: Tu captura de pantalla `@instancia_EC2.png`)*
    *   **Bucket S3:**
        *   Ve a la consola de AWS -> S3.
        *   Busca el bucket con el nombre que definiste (ej. `example-bucket-acbg-may25-us-east-1`).
        *   Confirma que exista.
        *   *(Referencia: Tu captura de pantalla `@bucket_S3.png`)*

2.  **Verificar el Dashboard en Datadog:**
    *   **Accede a tu Dashboard:**
        *   Ve a tu sitio de Datadog (ej. `https://app.us5.datadoghq.com`).
        *   Navega a "Dashboards" -> "Dashboard List".
        *   Busca y abre el dashboard llamado `"Dashboard KAI - Infra AWS"`.
        *   La URL directa al dashboard también se muestra como una salida de Terraform (`dashboard_url`).
    *   **Widget de CPU de EC2:**
        *   El widget "EC2 CPU usage (Average)" debería comenzar a mostrar datos después de unos minutos (generalmente 5-15 minutos) desde que la instancia EC2 se inició y la integración de AWS en Datadog recopiló las métricas.
        *   Si no ves datos, asegúrate de que:
            *   La instancia EC2 esté corriendo en la región correcta.
            *   La integración de AWS en Datadog esté correctamente configurada para tu cuenta de AWS y tenga habilitada la recolección de métricas para EC2 en esa región.
            *   Haya pasado suficiente tiempo para la propagación de métricas.
        *   *(Referencia: Tu captura de pantalla `@dashboard.png` - puede mostrar el widget inicialmente vacío, con una nota sobre el tiempo de espera)*

3.  **Revisar la Integración de AWS en Datadog (Si Hay Problemas con las Métricas):**
    *   En Datadog, ve a "Integrations" -> "AWS".
    *   Verifica el estado de tu cuenta integrada. Asegúrate de que no haya errores de configuración, que el rol IAM y el External ID sean correctos, y que la recolección de métricas para los servicios deseados (EC2, S3, etc.) esté habilitada.

---

## 7. Consideraciones Adicionales y Próximos Pasos

Este proyecto sienta las bases para un monitoreo robusto. Aquí algunas consideraciones y cómo puedes expandirlo:

1.  **Seguridad del Usuario IAM de Terraform:**
    *   La política `AdministratorAccess` usada para el usuario `terraform-provisioner` es muy permisiva. En un entorno de producción, **debes reemplazarla con una política personalizada que otorgue solo los permisos mínimos necesarios** para las acciones que Terraform realizará (principio de menor privilegio).

2.  **Gestión del Rol de Integración AWS-Datadog con Terraform:**
    *   Actualmente, asumimos que el rol IAM para la integración AWS-Datadog se configura manualmente. Podrías extender tu configuración de Terraform para gestionar también este rol y su política de confianza, usando la variable `external_id`.

3.  **Expandir el Monitoreo en el Dashboard:**
    *   **Métricas de S3:** Añade widgets para monitorear tu bucket S3 (ej. tamaño del bucket `aws.s3.bucket_size_bytes`, número de objetos `aws.s3.number_of_objects`).
    *   **Métricas de Red de EC2:** `aws.ec2.network_in`, `aws.ec2.network_out`.
    *   **Disponibilidad, Errores, Latencia:** Dependiendo de las aplicaciones que corran en tus EC2.

4.  **Instalar el Agente de Datadog en EC2:**
    *   Para obtener métricas mucho más detalladas del sistema operativo, procesos, consumo de memoria específico, logs, trazas de aplicaciones (APM) y más, necesitas instalar el Agente de Datadog directamente en tus instancias EC2.
    *   Puedes automatizar la instalación del agente usando el campo `user_data` en el recurso `aws_instance` de Terraform, o mediante herramientas de gestión de configuración (Ansible, Chef, Puppet).
    *   Ejemplo básico de `user_data` para instalar el agente (requiere tu API Key de Datadog como variable en `variables.tf` y pasada al `user_data`):
        ```hcl
        // En el recurso aws_instance "example_ec2"
        user_data = <<-EOF
                    #!/bin/bash
                    DD_API_KEY=${var.datadog_api_key} DD_SITE="${var.datadog_site}" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"
                    EOF
        ```
        (Asegúrate de que `var.datadog_api_key` y `var.datadog_site` estén disponibles en este contexto o pásalas de forma segura).

5.  **Crear Monitores y Alertas en Datadog:**
    *   Usa el recurso `datadog_monitor` en Terraform para crear alertas automáticas. Por ejemplo, una alerta si el uso de CPU de EC2 supera el 80% durante X minutos.
    *   Configura notificaciones a Slack, email, PagerDuty, etc.

6.  **Modularizar la Configuración de Terraform:**
    *   A medida que tu configuración crezca, considera usar Módulos de Terraform para organizar y reutilizar tu código.

7.  **Gestión de Estado Remoto de Terraform:**
    *   Para trabajo en equipo y mayor robustez, configura un backend remoto para el estado de Terraform (ej. usando un bucket S3 y DynamoDB).

8.  **Seguridad de Claves y Secretos:**
    *   Considera usar herramientas como HashiCorp Vault o AWS Secrets Manager para una gestión más segura de los secretos.

---

## 8. Troubleshooting / Solución de Problemas Comunes

Durante la configuración de este proyecto, podrías encontrar algunos de estos errores comunes:

*   **`InvalidClientTokenId` o `Error: validating provider credentials` (Error del proveedor AWS):**
    *   **Causa Principal:** Las credenciales de AWS (`aws_access_key` o `aws_secret_key`) que Terraform está usando son incorrectas, inválidas, pertenecen a un usuario inactivo, o el usuario no tiene los permisos necesarios.
    *   **Solución Detallada:**
        1.  Asegúrate de haber creado un usuario IAM dedicado para Terraform (ej. `terraform-provisioner`) y NO estar usando credenciales del usuario raíz.
        2.  Genera un nuevo par de claves de acceso (Access Key ID y Secret Access Key) para este usuario IAM.
        3.  Copia las claves **exactamente**, sin espacios adicionales.
        4.  Actualiza estas claves en tu archivo local `secrets.auto.tfvars.json` Y en los secretos de tu repositorio de GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
        5.  Verifica que el usuario IAM tenga los permisos adecuados (para este curso, se usó `AdministratorAccess` para simplificar, pero en producción usa permisos mínimos).

*   **Error `403 Forbidden` (Error del proveedor Datadog):**
    *   **Causa Principal:** Problema con las credenciales de Datadog (`datadog_api_key`, `datadog_app_key`) o la configuración del sitio (`datadog_site`).
    *   **Solución Detallada:**
        1.  **API Key / Application Key Inválidas:** Regenera tu API Key y tu Application Key en Datadog (Organization Settings -> API Keys / Application Keys). Cópialas cuidadosamente.
        2.  **Sitio Datadog Incorrecto (`datadog_site`):** Verifica la URL que usas para acceder a Datadog. Si es `https://app.us5.datadoghq.com`, entonces `datadog_site` debe ser `us5.datadoghq.com`. Actualiza esto en `secrets.auto.tfvars.json` y en el secreto `DATADOG_SITE` de GitHub.
        3.  **Ámbitos de la Application Key:** Asegúrate de que la Application Key tenga los permisos (ámbitos/scopes) necesarios. Para gestionar dashboards, se requieren `dashboards_read` y `dashboards_write`.

*   **Error `BucketAlreadyExists` (Al crear el bucket S3):**
    *   **Causa Principal:** Los nombres de los buckets S3 deben ser únicos globalmente en todo AWS.
    *   **Solución Detallada:** Modifica el nombre del bucket en tu `main.tf` (recurso `aws_s3_bucket`) para que sea único. Puedes añadir tus iniciales, la fecha actual, o un sufijo aleatorio. Ejemplo: `bucket = "mi-proyecto-acbg-may25-${var.aws_region}"`.

*   **Widget de Dashboard Vacío o con "No Data" (Especialmente para métricas de EC2):**
    *   **Causa Principal:** Las métricas pueden tardar en propagarse; la integración AWS-Datadog podría no estar completamente configurada; o la recolección de métricas para el servicio específico podría estar deshabilitada.
    *   **Solución Detallada:**
        1.  **Tiempo de Propagación:** Espera al menos 15-20 minutos después de que la instancia EC2 esté en ejecución.
        2.  **Verifica la Integración AWS en Datadog:** Ve a Datadog -> Integrations -> AWS. Confirma que tu cuenta AWS esté integrada, que el rol IAM y el External ID sean correctos, y que no haya errores.
        3.  **Habilita la Recolección de Métricas:** En la configuración de la integración de AWS en Datadog, ve a la pestaña "Metric Collection" y asegúrate de que la recolección esté habilitada para los servicios deseados (ej. EC2) y para la región correcta.
        4.  **Instancia en Ejecución:** Confirma que la instancia EC2 esté realmente en estado "ejecutándose" en la consola de AWS.

---

## 9. Conclusión (Anteriormente Sección 8)

Has aprendido a:
*   Configurar proveedores de **Datadog** y **AWS** en **Terraform**.
*   Crear un Dashboard básico en **Datadog** con métricas de **EC2**, un bucket **S3** y una instancia **EC2** de ejemplo.
*   Automatizar el despliegue mediante **GitHub Actions**.
*   Solucionar problemas comunes de autenticación y configuración.

**Próximos retos recomendados:** (Estos se movieron a la Sección 7)

---

## 10. Recursos y Referencias (Anteriormente Sección 9)

📖 [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
📖 [Terraform Datadog Provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
📖 [GitHub Actions: Terraform](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-powershell) (Enlace genérico, buscar "GitHub Actions Terraform workflow")
📖 [Datadog API Keys](https://docs.datadoghq.com/account_management/api-app-keys/#api-keys)
📖 [Datadog Application Keys](https://docs.datadoghq.com/account_management/api-app-keys/#application-keys)
📖 [Integración de AWS con Datadog](https://docs.datadoghq.com/integrations/amazon_web_services/)
📖 [Nombres de Buckets S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)

---

## ✅ ¿Este flujo dejará GitHub Actions completamente funcional?
Sí, siguiendo cada paso cuidadosamente (creando los secretos, configurando IAM, integrando proveedores, definiendo el workflow y verificando en Datadog), tu pipeline en GitHub Actions se ejecutará satisfactoriamente.
Asegurate de que:

1. Los **secretos** estén correctamente cargados en GitHub.

2. Las credenciales de AWS y Datadog sean válidas y tengan permisos suficientes.

3. No existan errores en los archivos `*.tf` (ejecuta localmente `terraform validate`).

Una vez desplegado, el workflow realizará `terraform init`, `plan` y `apply` de forma automática en cada push a `main`. El dashboard se creará o actualizará según tus cambios.

Si en algún momento necesitas más configuraciones (por ejemplo, roles de IAM más finos, provisión de instancias EC2 con etiquetas específicas o personalización avanzada del dashboard), bastará con agregar o modificar bloques de Terraform y el pipeline se encargará del resto.

---
