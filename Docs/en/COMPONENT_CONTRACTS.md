# Component Contracts

## Contract model

```swift
let spec = A11ySpec(
    id: "delete_button",
    label: "Delete item",
    hint: "Removes this item from the list",
    role: .button,
    state: nil,
    wcag: [.nameRoleValue, .targetSize],
    owner: .design,
    source: A11ySource(filePath: "FavoriteButton.swift", line: 42),
    actionType: .destructive
)
```

## Apply in UIKit

```swift
deleteButton.applyA11y(spec)
```

## Validate

```swift
let report = A11yAudit.validate(view: deleteButton, spec: spec)
```

## Fluent builder

```swift
A11yContract(view: deleteButton)
    .id("delete_button")
    .label("Delete item")
    .hint("Removes this item from the list")
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

Useful for SwiftUI and test-time report generation.

## Severity guide

| Severity | Examples |
|----------|----------|
| critical | Missing label, illegible contrast, unidentified destructive action |
| major | Small touch target, missing role, no Dynamic Type |
| minor | Missing hint on complex action, generic label |
| info | Documentation improvements, missing owner |

## Reports

Generate traceable reports for PR/CI:

- Markdown: human review
- JSON: machine processing
- Sonar: quality gates
- SARIF: GitHub Code Scanning
- JUnit: CI test results
