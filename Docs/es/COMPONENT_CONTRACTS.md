# Contratos de componentes

## Modelo de contrato

```swift
let spec = A11ySpec(
    id: "delete_button",
    label: "Eliminar elemento",
    hint: "Elimina este elemento de la lista",
    role: .button,
    state: nil,
    wcag: [.nameRoleValue, .targetSize],
    owner: .design,
    source: A11ySource(filePath: "FavoriteButton.swift", line: 42),
    actionType: .destructive
)
```

## Aplicar en UIKit

```swift
deleteButton.applyA11y(spec)
```

## Validar

```swift
let report = A11yAudit.validate(view: deleteButton, spec: spec)
```

## API fluida

```swift
A11yContract(view: deleteButton)
    .id("delete_button")
    .label("Eliminar elemento")
    .hint("Elimina este elemento de la lista")
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

Útil para SwiftUI y generación de reportes en tests.

## Guía de severidad

| Severidad | Ejemplos |
|-----------|----------|
| critical | Label ausente, contraste ilegible, acción destructiva sin identificación |
| major | Touch target pequeño, role ausente, sin Dynamic Type |
| minor | Hint ausente en acción compleja, label genérica |
| info | Mejoras de documentación, owner no definido |

## Reportes

Genera reportes rastreables para PR/CI:

- Markdown: revisión humana
- JSON: procesamiento automatizado
- Sonar: quality gates
- SARIF: GitHub Code Scanning
- JUnit: resultados de test en CI
