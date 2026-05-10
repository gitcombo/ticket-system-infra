# ticket-system-infra

Sistema de tickets e incidentes — capa de infraestructura como código.

**Universidad Galileo · Postgrado en Diseño y Desarrollo de Software**  
Cursos: *Infraestructura en la Nube* + *Optimizations and Performance*  
Ciclo: Mayo–Junio 2026

---

## Repositorio

Este repositorio contiene el diseño del sistema (curso de *Infraestructura en la Nube*) y el código de automatización Terraform + pipeline CI/CD (curso de *Optimizations and Performance*) para el mismo sistema. Ambos cursos trabajan sobre el mismo repositorio de forma iterativa.

## Estructura

```
infra/          → Código Terraform e infraestructura como código
k8s/            → Manifests de Kubernetes (EKS track)
.github/        → Pipelines de GitHub Actions
```

Ver [`infra/README.md`](infra/README.md) para instrucciones de uso.

## Deliveries

| Delivery | Tag | Fecha | Estado |
|---|---|---|---|
| D1 — Workspace Bootstrap & CI | `oyd-delivery-1` | 10 may 2026 | ✅ |
| D2 — Cómputo, Storage, BD | `oyd-delivery-2` | 21 may 2026 | ⏳ |
| D3 — Capa de Red | `oyd-delivery-3` | 7 jun 2026 | ⏳ |
| D4 — Asíncrono + CD | `oyd-delivery-4` | 21 jun 2026 | ⏳ |
| D5 — Seguridad + Observabilidad | `oyd-delivery-5` | 25 jun 2026 | ⏳ |