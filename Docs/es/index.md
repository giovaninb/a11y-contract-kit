<p align="center">
  <img src="assets/logo.png" alt="Logo de A11yContractKit" width="480">
</p>

# A11yContractKit

**A11yContractKit no es una herramienta mágica de conformidad WCAG.**

Es una capa de contratos de accesibilidad orientada a desarrolladores para apps iOS. Ayuda a equipos mobile a definir, validar, reportar y rastrear requisitos de accesibilidad desde componentes, tests y pipelines de CI.

> A11yContractKit no promete conformidad automática con WCAG.
>
> La propuesta es convertir la accesibilidad en contratos verificables de componente, con reportes rastreables para PR, QA, Sonar y CI.

## Qué es

A11yContractKit ayuda a detectar, documentar y prevenir problemas comunes de accesibilidad mobile alineados con principios WCAG. No reemplaza pruebas manuales con tecnologías asistivas ni auditorías formales de conformidad.

## Empieza aquí

| Recurso | Descripción |
|---------|-------------|
| [Instalación (README)](https://github.com/giovaninb/a11y-contract-kit#installation-spm) | Agregar vía Swift Package Manager |
| [A11yContractDemo](DEMO_APP.md) | App de demostración interactiva |
| [Contratos de componentes](COMPONENT_CONTRACTS.md) | Cómo declarar contratos |
| [Entrega de diseño](DESIGN_HANDOFF.md) | Checklist diseño → dev |

## Guías

- [Mapeo WCAG](WCAG_MAPPING.md) — reglas ↔ criterios WCAG
- [Exportación de correcciones](FIX_EXPORT.md) — cherry-pick de fixes (UIKit, Framework, SwiftUI)
- [Integración Sonar](SONAR_INTEGRATION.md) — reportes en SonarQube
- [Integración CI](CI_INTEGRATION.md) — GitHub Actions y Azure DevOps

## Módulos

| Módulo | Descripción |
|--------|-------------|
| `A11yContractCore` | Modelos, rule engine, contraste, baseline |
| `A11yContractUIKit` | Extensiones UIView, scanner, API fluida |
| `A11yContractSwiftUI` | Modifier + registry |
| `A11yContractReporter` | Markdown, JSON, Sonar, SARIF, JUnit, exportación cherry-pick |
| `A11yContractTesting` | A11yAudit + helpers XCTest |
| `A11yContractCLI` | Herramienta `a11y-contract` |

## Limitaciones

- No garantiza conformidad WCAG 2.1 AA
- El contraste depende de colores extraíbles en runtime
- SwiftUI usa modifiers + registry (sin introspección profunda)
- CLI ejecuta auditorías vía XCTest (runtime)

## Roadmap KMP

Planificado: módulo Kotlin Multiplatform con `commonMain`, adapters Compose (Android) y bridge iOS.
