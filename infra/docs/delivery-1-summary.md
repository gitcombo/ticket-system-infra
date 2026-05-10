# Delivery 1 — IaC Workspace Bootstrap & CI Pipeline

**Curso:** Optimizations and Performance — PDDS, Universidad Galileo  
**Fecha de entrega:** 10 de mayo de 2026  
**Tag:** `oyd-delivery-1`

---

## 1. Cloud Provider y Región

**Proveedor:** Amazon Web Services (AWS)  
**Región:** `us-east-1` (US East — N. Virginia)

**Justificación:** AWS fue elegido por dos razones principales. Primero, el sistema de tickets e incidentes diseñado en *Infraestructura en la Nube* utiliza servicios que tienen su mayor madurez y cobertura de documentación en AWS: SQS para la cola de escalamiento automático, ECS Fargate para el backend de la API, y RDS para la base de datos relacional de tickets. 

Segundo, `us-east-1` es la región con la mayor disponibilidad de servicios de AWS globalmente y tiene la latencia más baja hacia los servidores de GitHub Actions, lo que reduce el tiempo de ejecución del pipeline de CI.

---

## 2. Recurso Provisionado

**Recurso:** `aws_s3_bucket` — bucket de almacenamiento para adjuntos de tickets y reportes de resolución.

**Por qué este recurso primero:** El bucket S3 fue elegido como recurso de prueba de concepto porque:
  (a) es el recurso más simple de provisionar en AWS sin dependencias de red o IAM complejas, 
  (b) valida que el provider, las credenciales y el wiring de variables funcionan end-to-end, y 
  (c) es un componente real del sistema — en Delivery 2 se convertirá en el módulo de almacenamiento con versioning, lifecycle rules y cifrado en reposo.

**Nombre del bucket:** `ticket-system-dev-attachments-galileo-pdds`

**Extracto del `terraform plan`:**

```
Terraform will perform the following actions:

  # aws_s3_bucket.tickets will be created
  + resource "aws_s3_bucket" "tickets" {
      + bucket                      = "ticket-system-dev-attachments-galileo-pdds"
      + force_destroy               = true
      + id                          = (known after apply)
      + arn                         = (known after apply)
      + region                      = (known after apply)
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "ticket-system"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

> **Nota:** El extracto anterior es representativo. El plan real se publica automáticamente como comentario en cada PR por el pipeline de CI.

---

## 3. Arquitectura del Pipeline de CI

El pipeline está definido en `.github/workflows/terraform-ci.yml` y se dispara en cada Pull Request hacia la rama `main`.

**Pasos en orden:**

| # | Paso | Comando | Propósito |
|---|---|---|---|
| 1 | Format Check | `terraform fmt --check -recursive` | Detecta desviaciones del estilo canónico HCL. Bloquea el PR si algún archivo necesita reformateo. |
| 2 | Init | `terraform init -backend=false` | Descarga plugins del provider sin inicializar backend remoto. Verifica que las restricciones de versión resuelven. |
| 3 | Validate | `terraform validate` | Análisis estático del grafo de configuración. Detecta errores de tipo y variables faltantes sin llamadas a la API. |
| 4 | Plan | `terraform plan -var-file=envs/dev/dev.tfvars` | Genera plan real contra la API de AWS. Requiere credenciales en el runner. |
| 5 | PR Comment | `actions/github-script` | Publica el output del plan en una sección `<details>` colapsable. No bloqueante. |

**Estrategia de credenciales:** Las credenciales de AWS se inyectan exclusivamente como GitHub Actions Encrypted Secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`). No aparecen en ningún archivo `.tf`, `.yml` ni en el historial de commits. En Delivery 5 se migrarán a OIDC federation para eliminar las long-lived access keys.

---

## 4. Diseño de Variables

| Variable | Tipo | Descripción | Dev | Prod |
|---|---|---|---|---|
| `environment` | `string` | Controla naming, sizing y políticas de retención. Validado con `contains(["dev","prod"])`. | `"dev"` | `"prod"` |
| `project_name` | `string` | Prefijo en todos los nombres de recursos para evitar colisiones en la misma cuenta de AWS. | `"ticket-system"` | `"ticket-system"` |
| `region` | `string` | Región AWS donde se provisionan todos los recursos. | `"us-east-1"` | `"us-east-1"` |
| `tickets_bucket_suffix` | `string` | Sufijo para el nombre del bucket S3 (debe ser globalmente único en AWS). | `"galileo-pdds"` | TBD — se definirá en Delivery 2 con un sufijo de producción dedicado. |

**Diferencias clave dev vs prod:** En dev, `force_destroy = true` permite destruir el bucket con objetos (facilita iteraciones rápidas). En prod, este flag será `false` para proteger datos reales. El sufijo del bucket también será diferente para que dev y prod nunca compartan el mismo bucket accidentalmente.

---

## 5. Decisiones y Trade-offs

### Decisión 1 — Estado local en Deliveries 1–3

**Decisión:** Usar estado local (`terraform.tfstate`) en lugar de un backend remoto (S3 + DynamoDB lock) para los primeros tres Deliveries.

**Justificación:** El estado local simplifica el bootstrap del workspace porque no crea una dependencia circular: para tener un backend remoto en S3 hay que provisionar S3, pero S3 lo provisiona Terraform. Resolver esa bootstrap dependency agrega complejidad innecesaria en Delivery 1. El trade-off es que el estado no se comparte automáticamente entre miembros del equipo — cada uno debe coordinar quién corre `apply`. Este trade-off es aceptable en las primeras semanas del proyecto donde los cambios son pocos y coordinados. La migración al backend remoto es un requisito explícito de Delivery 2.

### Decisión 2 — Pinning de versiones con `~>` en lugar de versión exacta

**Decisión:** Usar `~> 5.0` para el provider de AWS y `~> 1.8` para Terraform en lugar de fijar una versión exacta (e.g., `= 5.47.0`).

**Justificación:** El operador `~>` (pessimistic constraint) permite actualizaciones de patch y minor dentro del rango especificado, lo que significa que el workspace recibe fixes de seguridad y bugs automáticamente sin cambios en el código. Fijar una versión exacta requeriría PRs manuales para cada actualización de patch, añadiendo overhead de mantenimiento sin beneficio real para un proyecto académico de 8 semanas. El riesgo de breaking changes dentro de un minor range (`~> 5.0`) es mínimo dado el versionado semántico del provider de AWS. En producción real se evaluaría un lockfile más estricto.

---

*Delivery 1 — Sistema de Tickets e Incidentes · PDDS Universidad Galileo · Mayo 2026*
