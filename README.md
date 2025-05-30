# Monitoreo con Datadog usando Terraform + GitHub Actions + AWS

Este proyecto tiene como objetivo automatizar, desplegar y monitorear la infraestructura de AWS utilizando Datadog, Terraform y GitHub Actions.

## Estructura del Proyecto

```plaintext
terraform-monitoring/
├── main.tf                        # Definición principal de proveedores y recursos
├── variables.tf                   # Variables sensibles y no sensibles
├── outputs.tf                     # Salidas útiles (URLs, IDs, etc.)
├── .gitignore                     # Regla para ignorar archivos locales
├── secrets.auto.tfvars.json       # (NO subir) Contiene secretos localmente
├── README.md                      # Este documento
└── .github/
    └── workflows/
        └── deploy.yml             # Pipeline de GitHub Actions
```

## Configuración

1. Clonar el repositorio y navegar al directorio del proyecto.
2. Crear el archivo `secrets.auto.tfvars.json` con las credenciales necesarias.
3. Configurar los secretos en GitHub para el pipeline de GitHub Actions.

## Uso

Ejecutar el pipeline de GitHub Actions para desplegar la infraestructura y monitorear los recursos en Datadog.

## 📚 Documentación Detallada

Para una guía completa sobre cómo utilizar y extender este proyecto de monitoreo, consulta los siguientes documentos en el directorio `docs/`:

*   **[Curso de Configuración Inicial (`docs/Curso_1.md`)](docs/Curso_1.md):** Pasos detallados para configurar el sistema de monitoreo base, incluyendo la creación de recursos en AWS, configuración de Datadog, y el pipeline de GitHub Actions.

*   **[Manual de Incorporación a Nueva Infraestructura (`docs/Integracion_Sistema_Monitoreo.md`)](docs/Integracion_Sistema_Monitoreo.md):** Guía para adaptar y extender este sistema de monitoreo a otros componentes y servicios de tu infraestructura AWS. 