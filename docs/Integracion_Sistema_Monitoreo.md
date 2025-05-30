# Manual de Incorporación del Sistema de Monitoreo a Nueva Infraestructura

> **"Extiende tu visibilidad: Integra y monitorea cualquier componente de tu infraestructura AWS con Datadog, de forma automatizada y segura."**

---

## 🔖 Índice

- [Manual de Incorporación del Sistema de Monitoreo a Nueva Infraestructura](#manual-de-incorporación-del-sistema-de-monitoreo-a-nueva-infraestructura)
  - [🔖 Índice](#-índice-1)
  - [1. Introducción y Alcance](#1-introducción-y-alcance)
    - [1.1. Propósito de Este Manual](#11-propósito-de-este-manual)
    - [1.2. Alcance del Sistema de Monitoreo Base](#12-alcance-del-sistema-de-monitoreo-base)
    - [1.3. ¿Qué Implica "Cualquier Infraestructura"?](#13-qué-implica-cualquier-infraestructura)
  - [2. Requisitos Mínimos y Prerrequisitos](#2-requisitos-mínimos-y-prerrequisitos)
    - [2.1. Cuentas y Acceso](#21-cuentas-y-acceso)
    - [2.2. Herramientas y Conocimientos](#22-herramientas-y-conocimientos)
    - [2.3. Configuración Base Existente](#23-configuración-base-existente)
  - [3. Proceso de Incorporación Paso a Paso](#3-proceso-de-incorporación-paso-a-paso)
    - [3.1. Fase 1: Análisis y Diseño](#31-fase-1-análisis-y-diseño)
    - [3.2. Fase 2: Preparación de AWS y Datadog](#32-fase-2-preparación-de-aws-y-datadog)
    - [3.3. Fase 3: Adaptación de la Configuración de Terraform](#33-fase-3-adaptación-de-la-configuración-de-terraform)
    - [3.4. Fase 4: Configuración de Secretos y Variables](#34-configuración-de-secretos-y-variables)
    - [3.5. Fase 5: Pruebas Locales](#35-fase-5-pruebas-locales)
    - [3.6. Fase 6: Despliegue con CI/CD (GitHub Actions)](#36-fase-6-despliegue-con-cicd-github-actions)
    - [3.7. Fase 7: Validación y Ajustes Post-Despliegue](#37-fase-7-validación-y-ajustes-post-despliegue)
  - [4. Consideraciones Clave para la Extensión](#4-consideraciones-clave-para-la-extensión)
    - [4.1. Principio de Menor Privilegio (IAM)](#41-principio-de-menor-privilegio-iam)
    - [4.2. Nomenclatura y Tags](#42-nomenclatura-y-tags)
    - [4.3. Modularidad en Terraform](#43-modularidad-en-terraform)
    - [4.4. Gestión de Estado Remoto de Terraform](#44-gestión-de-estado-remoto-de-terraform)
    - [4.5. Agentes de Datadog](#45-agentes-de-datadog)
  - [5. Ejemplo Práctico (Extensión Hipotética)](#5-ejemplo-práctico-extensión-hipotética)
  - [6. Conclusión](#6-conclusión)

---

## 1. Introducción y Alcance

### 1.1. Propósito de Este Manual

Este manual proporciona una guía detallada para extender el sistema de monitoreo base (documentado en `Curso_1.md`) para incorporar y monitorear nuevos componentes o tipos de infraestructura dentro de tu entorno AWS, utilizando Datadog, Terraform y GitHub Actions. El objetivo es mantener un enfoque automatizado, reproducible y seguro.

### 1.2. Alcance del Sistema de Monitoreo Base

El sistema base, tal como se describe en `Curso_1.md`, establece:
- Un dashboard en Datadog.
- Una instancia EC2 de ejemplo.
- Un bucket S3 de ejemplo.
- Un pipeline de CI/CD con GitHub Actions para desplegar estos recursos.
- Gestión segura de credenciales.

Este sistema sirve como una plantilla y un conjunto de herramientas fundamentales.

### 1.3. ¿Qué Implica "Cualquier Infraestructura"?

"Cualquier infraestructura" se refiere a la capacidad de adaptar el sistema base para monitorear una variedad más amplia de servicios y recursos de AWS, tales como:
- Otras instancias EC2 con roles específicos.
- Bases de datos RDS.
- Balanceadores de carga (ALB/NLB).
- Funciones Lambda.
- Clústeres ECS/EKS.
- Cualquier otro recurso AWS del que Datadog pueda recolectar métricas.

La "cualquier" parte implica que el **proceso** es adaptable, no que el código actual funcione sin cambios para todo.

---

## 2. Requisitos Mínimos y Prerrequisitos

### 2.1. Cuentas y Acceso

- **Cuenta AWS Activa:** Con permisos suficientes para:
    - Crear y modificar los nuevos tipos de recursos que se desean monitorear (ej. RDS, Lambda, etc.).
    - Modificar políticas IAM y roles, específicamente el rol `DatadogIntegrationRole` (o el que se utilice para la integración AWS-Datadog) para asegurar que Datadog tenga permisos de lectura sobre los nuevos recursos.
- **Cuenta Datadog Activa:**
    - API Key y Application Key con los ámbitos necesarios (mínimo `dashboards_read`, `dashboards_write`; potencialmente otros según los recursos Datadog a gestionar, como `monitors_read`, `monitors_write`).
    - Sitio Datadog (`datadog_site`) correctamente identificado.
- **Repositorio GitHub (o similar):** Para el código IaC y el pipeline CI/CD.

### 2.2. Herramientas y Conocimientos

- **Terraform:** Comprensión de cómo definir recursos, usar variables, proveedores y (preferiblemente) módulos.
- **AWS:** Familiaridad con los servicios AWS que se van a incorporar y sus métricas relevantes.
- **Datadog:** Conocimiento básico de cómo funcionan las métricas, dashboards y (opcionalmente) monitores en Datadog.
- **Git:** Para control de versiones.
- **GitHub Actions (o CI/CD equivalente):** Entender cómo funcionan los workflows, secretos y variables de entorno.

### 2.3. Configuración Base Existente

Se asume que los siguientes componentes del sistema de monitoreo base ya están configurados y funcionales:
- Usuario IAM para Terraform (ej. `terraform-provisioner`) con una política de permisos base (aunque se deberá revisar y ampliar).
- Integración AWS-Datadog configurada manualmente en Datadog, incluyendo el rol IAM en AWS (ej. `DatadogIntegrationRole`) y el External ID.
- El proyecto Terraform base (`main.tf`, `variables.tf`, etc.) clonado y accesible.
- Pipeline de GitHub Actions básico funcionando.

---

## 3. Proceso de Incorporación Paso a Paso

### 3.1. Fase 1: Análisis y Diseño

1.  **Identificar Componentes a Monitorear:**
    *   ¿Qué nuevos servicios o recursos de AWS se quieren añadir al monitoreo? (Ej. una base de datos RDS Aurora, un grupo de Auto Scaling de EC2, funciones Lambda específicas).
2.  **Definir Métricas Clave:**
    *   Para cada nuevo componente, ¿cuáles son las métricas más importantes para su salud y rendimiento? (Ej. para RDS: `CPUUtilization`, `FreeStorageSpace`, `DBConnections`; para Lambda: `Invocations`, `Errors`, `Duration`).
    *   Consulta la documentación de Datadog para las métricas disponibles para cada servicio AWS.
3.  **Diseñar el Dashboard (o Actualizarlo):**
    *   ¿Cómo se visualizarán estas nuevas métricas? ¿Nuevos widgets en el dashboard existente? ¿Un nuevo dashboard?
    *   ¿Qué tipo de gráficos son los más adecuados? (Timeseries, Query Value, Table, etc.).

### 3.2. Fase 2: Preparación de AWS y Datadog

1.  **Revisar/Actualizar Permisos del Usuario IAM de Terraform (`terraform-provisioner`):**
    *   Asegúrate de que la política adjunta al usuario `terraform-provisioner` le permita crear/modificar/eliminar los nuevos tipos de recursos AWS que se añadirán. (Ej. si añades RDS, necesita permisos como `rds:CreateDBInstance`, `rds:DescribeDBInstances`, etc.).
    *   Sigue el principio de menor privilegio.
2.  **Revisar/Actualizar Permisos del Rol de Integración AWS-Datadog (`DatadogIntegrationRole`):**
    *   La política adjunta a este rol (ej. `DatadogAWSIntegrationPolicy` o una personalizada) debe permitir a Datadog leer las métricas de los nuevos servicios.
    *   Si Datadog no tiene permisos, no podrá obtener las métricas. Por ejemplo, para RDS, necesitaría permisos como `rds:Describe*`, `pi:*` (si usas Performance Insights).
    *   Datadog suele proporcionar guías o políticas actualizadas para esto.

### 3.3. Fase 3: Adaptación de la Configuración de Terraform

1.  **`main.tf`:**
    *   **Nuevos Recursos AWS:** Añade los bloques `resource "aws_..."` necesarios para definir la nueva infraestructura que quieres gestionar y, por ende, monitorear. (Ej. `resource "aws_db_instance" "mi_basedatos" {...}`).
    *   **Data Sources (Opcional):** Puedes usar `data "aws_..."` para referenciar recursos existentes si no los gestionas directamente con este Terraform.
    *   **Actualizar Dashboard Datadog:**
        *   Añade nuevos bloques `widget {}` dentro del recurso `datadog_dashboard.dashboard_kai` (o crea un nuevo recurso `datadog_dashboard`).
        *   Define las `request` con las consultas Datadog (`q = "..."`) para las nuevas métricas identificadas. Ejemplo para RDS CPU: `q = "avg:aws.rds.cpuutilization{dbinstanceidentifier:mi_basedatos_id} by {dbinstanceidentifier}"`
2.  **`variables.tf`:**
    *   Añade nuevas variables si son necesarias para parametrizar los nuevos recursos. (Ej. `variable "rds_instance_class" { type = string ... }`, `variable "lambda_function_name" { type = string ... }`).
    *   Marca las variables sensibles con `sensitive = true`.
3.  **`outputs.tf`:**
    *   Añade nuevas salidas si quieres exponer información sobre los nuevos recursos creados (ej. el endpoint de una base de datos RDS, el ARN de una función Lambda).

### 3.4. Fase 4: Configuración de Secretos y Variables

1.  **Actualizar `secrets.auto.tfvars.json` (Local):**
    *   Si añadiste nuevas variables en `variables.tf` que son sensibles o específicas del entorno, añádelas a este archivo para pruebas locales.
2.  **Actualizar Secretos en GitHub Actions:**
    *   Si las nuevas variables son sensibles y necesarias para el pipeline, añádelas como secretos en la configuración de tu repositorio GitHub (Settings -> Secrets and variables -> Actions).
    *   Actualiza el bloque `env` en tu archivo `.github/workflows/deploy.yml` para mapear estos nuevos secretos a variables `TF_VAR_`.

### 3.5. Fase 5: Pruebas Locales

Es crucial probar los cambios localmente antes de hacer push al repositorio y disparar el pipeline de CI/CD.

1.  **Inicializar Terraform (si hay nuevos proveedores o módulos):**
    ```bash
    terraform init
    # o terraform init -upgrade
    ```
2.  **Validar la Configuración:**
    ```bash
    terraform validate
    ```
3.  **Planificar los Cambios:**
    ```bash
    terraform plan
    ```
    Revisa cuidadosamente el plan. Asegúrate de que Terraform va a crear/modificar los recursos correctos y que no hay acciones destructivas inesperadas.
4.  **Aplicar los Cambios (Localmente):**
    ```bash
    terraform apply
    # o terraform apply -auto-approve (con precaución)
    ```

### 3.6. Fase 6: Despliegue con CI/CD (GitHub Actions)

1.  **Hacer Commit y Push de los Cambios:**
    ```bash
    git add .
    git commit -m "feat: Incorporar monitoreo para [NUEVA INFRAESTRUCTURA]"
    git push origin main # O la rama configurada en tu workflow
    ```
2.  **Monitorear el Workflow:**
    *   Ve a la pestaña "Actions" en tu repositorio GitHub.
    *   Observa la ejecución del workflow. Verifica que todos los pasos (`init`, `validate`, `plan`, `apply`) se completen exitosamente.

### 3.7. Fase 7: Validación y Ajustes Post-Despliegue

1.  **Verificar Recursos en AWS:**
    *   Confirma en la consola de AWS que los nuevos recursos se hayan creado/modificado según lo esperado.
2.  **Verificar Dashboard en Datadog:**
    *   Abre el dashboard en Datadog.
    *   Verifica que los nuevos widgets estén presentes y comiencen a mostrar datos. Recuerda que puede haber un retraso (5-15 minutos o más) para que las métricas se propaguen.
3.  **Troubleshooting (Si es Necesario):**
    *   Si los widgets no muestran datos:
        *   Revisa la configuración de la Integración AWS en Datadog (permisos, recolección de métricas para el nuevo servicio/región).
        *   Verifica que las consultas en los widgets del dashboard sean correctas.
        *   Revisa los logs del agente de Datadog si estás usando agentes.
        *   Consulta la sección de Troubleshooting en `Curso_1.md`.

---

## 4. Consideraciones Clave para la Extensión

### 4.1. Principio de Menor Privilegio (IAM)

A medida que añades más tipos de recursos, revisa y ajusta continuamente las políticas IAM para el usuario `terraform-provisioner` y el rol `DatadogIntegrationRole` para otorgar solo los permisos estrictamente necesarios.

### 4.2. Nomenclatura y Tags

Establece y sigue una convención de nomenclatura consistente para tus recursos y utiliza tags de AWS de manera efectiva para organizar, filtrar y gestionar costos.

### 4.3. Modularidad en Terraform

Si la configuración de un tipo particular de infraestructura se vuelve compleja o se repite, considera crear módulos de Terraform para encapsularla y reutilizarla.

### 4.4. Gestión de Estado Remoto de Terraform

Para trabajo en equipo y mayor robustez, es altamente recomendable configurar un backend remoto para el estado de Terraform (ej. usando un bucket S3 y DynamoDB para el bloqueo de estado).

### 4.5. Agentes de Datadog

Para un monitoreo más profundo a nivel de sistema operativo, procesos, logs de aplicaciones y trazas (APM), necesitarás instalar y configurar agentes de Datadog en tus instancias computacionales (EC2, contenedores ECS/EKS, etc.). Esto se puede automatizar usando `user_data` en Terraform, herramientas de gestión de configuración, o integraciones de Datadog para servicios de contenedores.

---

## 5. Ejemplo Práctico (Extensión Hipotética)

(Esta sección se puede desarrollar con un ejemplo concreto, como añadir una base de datos RDS y un widget para monitorear sus conexiones).

---

## 6. Conclusión

Siguiendo este proceso, puedes extender sistemáticamente tu sistema de monitoreo para cubrir una amplia gama de infraestructuras en AWS. La clave es el análisis cuidadoso, la adaptación iterativa de tu código Terraform y la validación continua. Este enfoque te permite mantener la automatización, reproducibilidad y seguridad a medida que tu entorno crece. 