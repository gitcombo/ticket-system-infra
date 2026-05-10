# ticket-system — Infraestructura Terraform

Sistema de tickets e incidentes · Universidad Galileo · Postgrado PDDS · Mayo–Junio 2026

---

## Requisitos

| Herramienta | Versión mínima |
|---|---|
| Terraform | 1.8.x |
| AWS CLI | 2.x |
| Git | 2.x |

---

## Credenciales de AWS

Las credenciales **nunca se hardcodean** en archivos `.tf` ni en el repositorio.

### Opción A — Variables de entorno (local)

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_REGION="us-east-1"
```

### Opción B — AWS CLI profile

```bash
aws configure --profile ticket-system-dev
export AWS_PROFILE=ticket-system-dev
```

En el pipeline de CI las credenciales se inyectan como **GitHub Actions Encrypted Secrets** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`). Ver sección de CI más abajo.

---

## Inicializar el workspace

```bash
cd infra/

# Descarga los plugins del provider (estado local, sin backend remoto)
terraform init

# Verifica el formato de todos los archivos .tf
terraform fmt -recursive

# Validación estática (sin llamadas a la API)
terraform validate
```

---

## Generar un plan

```bash
# Plan contra el entorno dev
terraform plan -var-file=envs/dev/dev.tfvars -out=tfplan

# Ver el plan en detalle
terraform show tfplan
```

---

## Aplicar cambios

```bash
terraform apply tfplan
```

> **Nota:** El estado se guarda localmente en `terraform.tfstate`. No subir este archivo con credenciales o datos sensibles a un repositorio público. El archivo está en `.gitignore` solo a partir de Delivery 2 cuando se migra a backend remoto.

---

## Destruir recursos

```bash
terraform destroy -var-file=envs/dev/dev.tfvars
```

---

## Estructura del repositorio

```
infra/
├── provider.tf          # Provider AWS + versiones
├── variables.tf         # Variables de entrada (4+)
├── outputs.tf           # Outputs expuestos (2+)
├── main.tf              # Recursos principales
├── envs/
│   ├── dev/dev.tfvars   # Valores para desarrollo
│   └── prod/prod.tfvars # Valores para producción (Delivery 2+)
├── modules/             # Módulos reutilizables (Delivery 2+)
├── docs/                # Resúmenes MD de cada Delivery
└── README.md            # Este archivo
.github/
└── workflows/
    └── terraform-ci.yml # Pipeline CI en cada PR a main
```

---

## CI/CD — GitHub Actions

El pipeline se dispara en cada Pull Request hacia `main`. Pasos en orden:

| Paso | Comando | Qué verifica |
|---|---|---|
| 1 | `terraform fmt --check -recursive` | Formato canónico HCL |
| 2 | `terraform init -backend=false` | Resolución de versiones del provider |
| 3 | `terraform validate` | Análisis estático sin llamadas a la API |
| 4 | `terraform plan -var-file=envs/dev/dev.tfvars` | Plan real contra AWS |
| 5 | Post plan como comentario en el PR | Visibilidad del plan para revisión |

Los pasos 1–4 **bloquean el PR** si fallan. El paso 5 es no-bloqueante.

### Secretos requeridos en GitHub

Ir a `Settings → Secrets and variables → Actions` y agregar:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (valor: `us-east-1`)

---

## Variables de entorno

| Variable | Tipo | Dev | Prod |
|---|---|---|---|
| `environment` | `string` | `"dev"` | `"prod"` |
| `project_name` | `string` | `"ticket-system"` | `"ticket-system"` |
| `region` | `string` | `"us-east-1"` | `"us-east-1"` |
| `tickets_bucket_suffix` | `string` | `"galileo-pdds"` | TBD en Delivery 2 |

---

## Entregables por Delivery

| Delivery | Fecha | Qué agrega |
|---|---|---|
| D1 | 10 may | Workspace + CI pipeline (este estado) |
| D2 | 21 may | Módulos de cómputo, almacenamiento y BD |
| D3 | 7 jun | Capa de red (VPC, subnets, NAT) |
| D4 | 21 jun | Infraestructura asíncrona + pipeline CD |
| D5 | 25 jun | Seguridad, observabilidad, one-click deployment |
