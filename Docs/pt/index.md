# A11yContractKit

**A11yContractKit não é uma ferramenta mágica de conformidade WCAG.**

É uma camada de contratos de acessibilidade focada em desenvolvedores para apps iOS. Ajuda times mobile a definir, validar, reportar e rastrear requisitos de acessibilidade direto de componentes, testes e pipelines de CI.

> A11yContractKit não promete conformidade automática com WCAG.
>
> A proposta é transformar acessibilidade em contrato verificável de componente, com relatórios rastreáveis para PR, QA, Sonar e CI.

## O que é

A11yContractKit ajuda times a detectar, documentar e prevenir problemas comuns de acessibilidade mobile alinhados aos princípios WCAG. Não substitui testes manuais com tecnologias assistivas nem auditorias formais de conformidade.

## Comece aqui

| Recurso | Descrição |
|---------|-----------|
| [Instalação (README)](https://github.com/giovaninb/a11y-contract-kit#installation-spm) | Adicione via Swift Package Manager |
| [A11yContractDemo](DEMO_APP.md) | App de demonstração interativo |
| [Contratos de componente](COMPONENT_CONTRACTS.md) | Como declarar contratos |
| [Handoff de design](DESIGN_HANDOFF.md) | Checklist design → dev |

## Guias

- [Mapeamento WCAG](WCAG_MAPPING.md) — regras ↔ critérios WCAG
- [Integração Sonar](SONAR_INTEGRATION.md) — relatórios no SonarQube
- [Integração CI](CI_INTEGRATION.md) — GitHub Actions e Azure DevOps

## Módulos

| Módulo | Descrição |
|--------|-----------|
| `A11yContractCore` | Modelos, rule engine, contraste, baseline |
| `A11yContractUIKit` | Extensões UIView, scanner, API fluente |
| `A11yContractSwiftUI` | Modifier + registry |
| `A11yContractReporter` | Markdown, JSON, Sonar, SARIF, JUnit |
| `A11yContractTesting` | A11yAudit + helpers XCTest |
| `A11yContractCLI` | Ferramenta `a11y-contract` |

## Limitações

- Não garante conformidade WCAG 2.1 AA
- Contraste depende de cores extraíveis em runtime
- SwiftUI usa modifiers + registry (sem introspecção profunda)
- CLI executa auditoria via XCTest (runtime)

## Roadmap KMP

Planejado: módulo Kotlin Multiplatform com `commonMain`, adapters Compose (Android) e bridge iOS.
