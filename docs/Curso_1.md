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
  - [2. Configuración de Datadog](#2-configuración-de-datadog)
  - [3. Archivos de Terraform](#3-archivos-de-terraform)
    - [3.1. `main.tf`](#31-maintf)
    - [3.2. `variables.tf`](#32-variablestf)
    - [3.3. `outputs.tf`](#33-outputstf)
    - [3.4. `.gitignore`](#34-gitignore)
  - [4. Configuración de GitHub Actions](#4-configuración-de-github-actions)
    - [4.1. `.github/workflows/deploy.yml`](#41-githubworkflowsdeployyml)
  - [5. Puesta en Práctica Paso a Paso](#5-puesta-en-práctica-paso-a-paso)
    - [5.1. Clonar y Preparar el Repositorio](#51-clonar-y-preparar-el-repositorio)
    - [5.2. Agregar Secretos a GitHub](#52-agregar-secretos-a-github)
    - [5.3. Verificar Variables de Entorno](#53-verificar-variables-de-entorno)
    - [5.4. Ejecutar GitHub Action Manual (Opcional)](#54-ejecutar-github-action-manual-opcional)
  - [6. Validación en Datadog](#6-validación-en-datadog)
  - [7. Consideraciones Adicionales](#7-consideraciones-adicionales)
  - [8. Conclusión y Próximos Pasos](#8-conclusión-y-próximos-pasos)
  - [9. Recursos y Referencias](#9-recursos-y-referencias)
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
Para que Terraform pueda crear recursos en AWS (instancias EC2, buckets S3, roles, etc.), necesitamos:

1. Crear un usuario IAM (o rol) con políticas mínimas para administrar

	- AmazonEC2FullAccess

	- AmazonS3ReadOnlyAccess (o mayor si vas a crear/configurar buckets)

	- IAMFullAccess (o políticas limitadas para roles específicos)

2. Obtener las credenciales:

	- `AWS_ACCESS_KEY_ID`

	- `AWS_SECRET_ACCESS_KEY`

3. (Opcional) Si quieres usar un perfil local en tu máquina, configura `~/.aws/credentials`:
```ini
[default]
aws_access_key_id     = TU_ACCESS_KEY_ID
aws_secret_access_key = TU_SECRET_ACCESS_KEY
```

---

4. Define la región en variables.tf o en un archivo `secrets.auto.tfvars.json`:
```json
{
  "aws_region": "us-east-1"
}
```

---

## 2. Configuración de Datadog
1. En tu cuenta de Datadog, ve a Integrations → APIs y copia:

	- Datadog API Key

	- Datadog Application Key

2. Configura las integraciones nativas de AWS dentro de Datadog:

	- Amazon EC2

	- Amazon S3
	Esto ya lo completaste, así que Datadog recibirá métricas de tus instancias EC2 y buckets S3.

3. Para la región correcta, anota el parámetro `site`:

	- `datadoghq.com` (US)

	- `datadoghq.eu` (Europa)
 

---

## 3. Archivos de Terraform
### 3.1. `main.tf`
```hclterraform {
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
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#######################################
# Ejemplo de Dashboard en Datadog
#######################################
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
```
> ● Nota: Ajusta la consulta `q` según las etiquetas de tus recursos AWS.

---

### 3.2. `variables.tf`
```hcl
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
```

---

### 3.3. `outputs.tf`
```hcl
output "dashboard_url" {
  value       = "https://app.${var.datadog_site}/dashboard/lists"
  description = "URL base para ver dashboards en Datadog"
}

output "aws_region_out" {
  value       = var.aws_region
  description = "Región de AWS utilizada"
}
```

---

### 3.4. `.gitignore`

```gitignore
# Ignorar archivos y directorios generados por Terraform
.terraform/
*.tfstate
*.tfstate.backup
terraform.tfvars
terraform.tfvars.json
.terraform.lock.hcl

# Ignorar credenciales locales (se suben como secretos en GitHub)
secrets.auto.tfvars.json

# Ignorar archivos temporales de editor y sistema operativo
.vscode/
.DS_Store
Thumbs.db
desktop.ini

# Ignorar logs o archivos temporales
*.log
*.tmp
*.bak


```
---

## 4. Configuración de GitHub Actions
### 4.1. `.github/workflows/deploy.yml`
```yaml
name: Terraform Deploy - Datadog + AWS

on:
  push:
    branches:
      - main

jobs:
  terraform:
    name: Apply Terraform
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.4.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -input=false

      - name: Terraform Apply
        run: terraform apply -auto-approve -input=false
        env:
          TF_VAR_datadog_api_key: ${{ secrets.DATADOG_API_KEY }}
          TF_VAR_datadog_app_key: ${{ secrets.DATADOG_APP_KEY }}
          TF_VAR_datadog_site: ${{ secrets.DATADOG_SITE }}
          TF_VAR_aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          TF_VAR_aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_aws_region: ${{ secrets.AWS_REGION }}
```
> 🔑 Asegúrate de que en Settings → Secrets and variables → Actions de tu repo estén definidos los secretos:

* "DATADOG_API_KEY"

* "DATADOG_APP_KEY"

* "DATADOG_SITE"

* "AWS_ACCESS_KEY_ID"

* "AWS_SECRET_ACCESS_KEY"

* "AWS_REGION" 

---

## 5. Puesta en Práctica Paso a Paso

### 5.1. Clonar y Preparar el Repositorio

```bash
# Desde tu computador local
git clone https://github.com/TU_USUARIO/terraform-monitoring.git
cd terraform-monitoring
```
1. Comprueba que tengas los archivos:

	- `main.tf`, `variables.tf`, `outputs.tf`, `.gitignore`, `.github/workflows/deploy.yml`, `README.md`.

2. Crea tu archivo local de variables (no subirlo):

```bash
cat > secrets.auto.tfvars.json <<EOF
{
  "datadog_api_key":     "TU_DATADOG_API_KEY",
  "datadog_app_key":     "TU_DATADOG_APP_KEY",
  "datadog_site":        "datadoghq.com",
  "aws_access_key":      "TU_AWS_ACCESS_KEY_ID",
  "aws_secret_key":      "TU_AWS_SECRET_ACCESS_KEY",
  "aws_region":          "us-east-1"
}
EOF
```

3. Verifica que tu `.gitignore` incluya `secrets.auto.tfvars.json`.

---

### 5.2. Agregar Secretos a GitHub
Entra a tu repositorio en GitHub:

1. Ve a **Settings** → **Secrets and variables** → **Actions**

2. Crea los siguientes secretos (los valores reales vienen de **AWS** y **Datadog**):

	- `DATADOG_API_KEY`

	- `DATADOG_APP_KEY`

	- `DATADOG_SITE` (ejemplo: `datadoghq.com`)

	- `AWS_ACCESS_KEY_ID`

	- `AWS_SECRET_ACCESS_KEY`

	- `AWS_REGION `(ejemplo: `us-east-1`)

---

### 5.3. Verificar Variables de Entorno
Para que Terraform lea los valores, el GitHub Action exporta las variables `TF_VAR_*` en el entorno. No hace falta modificar `main.tf`. Confirmá que en `variables.tf` los nombres coincidan:
```hcl
variable "datadog_api_key"     { type = string sensitive = true }
variable "datadog_app_key"     { type = string sensitive = true }
variable "datadog_site"        { type = string default = "datadoghq.com" }
variable "aws_access_key"      { type = string sensitive = true }
variable "aws_secret_key"      { type = string sensitive = true }
variable "aws_region"          { type = string default = "us-east-1" }
```

---

### 5.4. Ejecutar GitHub Action Manual (Opcional)
Si querés probar localmente antes de hacer un push, podés simular con:
```bash
# Instala act (GitHub Actions local runner), opcional:
# https://github.com/nektos/act
act push -b main
```
> Pero no es obligatorio: simplemente hacer git push a la rama main disparará el workflow.

---

## 6. Validación en Datadog
1. Ingresá a tu cuenta de Datadog → **Dashboards** → **Lists**

2. Deberías ver un dashboard llamado **"Dashboard KAI - Infra AWS"**

3. Dentro del dashboard, encontrarás tu gráfico de **EC2 CPU usage** con datos en tiempo real (si tu agente EC2 está enviado métricas)

4. Revisa la sección de **Integrations → AWS** para verificar que la integración EC2 y S3 reciban correctamente métricas.

---

## 7. Consideraciones Adicionales
1. **Roles y Políticas IAM**

	- Recomendación: crear un rol IAM con permisos limitados para Terraform, no usar root.

	- Ejemplo: política JSON con permisos mínimos para `ec2:DescribeInstances`, `s3:ListBucket`, `iam:GetUser`, etc.

2. **Gestión de Versiones de Provider**

	- El archivo `.terraform.lock.hcl` mantiene bloqueos de versiones; en proyectos de equipo, SÍ conviene subirlo.

	- Para un proyecto personal, podés agregar `.terraform.lock.hcl` a `.gitignore`.

3. **Seguridad en el `secrets.auto.tfvars.json`**

	- **Nunca subas este archivo a GitHub.**

	- Ignóralo en `.gitignore`.

4. **Pruebas y Validaciones**

	- Antes de aplicar en `main`, crea una rama `dev` y PR para validar políticas y revisar outputs.

	- Ejecutá `terraform fmt` y `terraform validate` como pasos previos.

5. **Mantenimiento del Dashboard**

	- Cada vez que modifiques la sección de `resource "datadog_dashboard"`, el workflow hará un `terraform apply` y actualizará el dashboard sin perder configuraciones previas.


---

## 8. Conclusión y Próximos Pasos
Has aprendido a:

	- Configurar proveedores de **Datadog** y **AWS** en **Terraform**.

	- Crear un Dashboard básico en **Datadog** con métricas de **EC2**.

	- Automatizar el despliegue mediante **GitHub Actions**.

**Próximos retos recomendados:**
1. Agregar Monitoreo de **S3**

	- Crea un widget que muestre la métrica `aws.s3.bucket_size_bytes{*}`

	- Ajusta `main.tf` con un nuevo bloque `widget { ... }`

2. Crear Alertas (**Monitors**)

	- Usar recurso `datadog_monitor` para enviar alertas a Slack o correo si la **CPU** de **EC2** supera un umbral.

3. Incorporar Logs

	- Instalar y configurar el **Datadog Agent** en tus instancias **EC2** para capturar logs del sistema y aplicaciones.

4. Modularizar Terraform

	- Mover la definición del dashboard a un módulo separado en `modules/datadog_dashboard/`

5. Integrar con KAI

	- Evaluar si tu agente KAI debe desplegar o modificar dashboards dinámicamente.

---

## 9. Recursos y Referencias
📖 Terraform AWS Provider

📖 Terraform Datadog Provider

📖 GitHub Actions: Terraform

📖 Datadog API Keys

📖 Integraciones AWS en Datadog


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
