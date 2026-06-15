# Contratos de componente

## Modelo de contrato

```swift
let spec = A11ySpec(
    id: "delete_button",
    label: "Excluir item",
    hint: "Remove este item da lista",
    role: .button,
    state: nil,
    wcag: [.nameRoleValue, .targetSize],
    owner: .design,
    source: A11ySource(filePath: "FavoriteButton.swift", line: 42),
    actionType: .destructive
)
```

## Aplicar no UIKit

```swift
deleteButton.applyA11y(spec)
```

## Validar

```swift
let report = A11yAudit.validate(view: deleteButton, spec: spec)
```

## API fluente

```swift
A11yContract(view: deleteButton)
    .id("delete_button")
    .label("Excluir item")
    .hint("Remove este item da lista")
    .role(.button)
    .minimumTouchTarget(44)
    .wcag(.nameRoleValue, .targetSize)
    .validate()
```

## Registry

```swift
A11yContractRegistry.shared.register(spec)
let specs = A11yContractRegistry.shared.allSpecs()
```

Útil para SwiftUI e geração de relatórios em testes.

## Guia de severidade

| Severidade | Exemplos |
|------------|----------|
| critical | Label ausente, contraste ilegível, ação destrutiva sem identificação |
| major | Touch target pequeno, role ausente, sem Dynamic Type |
| minor | Hint ausente em ação complexa, label genérica |
| info | Melhorias de documentação, owner não definido |

## Relatórios

Gere relatórios rastreáveis para PR/CI:

- Markdown: revisão humana
- JSON: processamento automatizado
- Sonar: quality gates
- SARIF: GitHub Code Scanning
- JUnit: resultados de teste em CI
