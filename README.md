# A11yContractKit

**A11yContractKit is not a magic WCAG compliance tool.**

It is a developer-first accessibility contract layer for iOS apps. It helps mobile teams define, validate, report, and track accessibility requirements directly from components, tests, and CI pipelines.

> A11yContractKit não promete conformidade automática com WCAG.
>
> A proposta é transformar acessibilidade em contrato verificável de componente, com relatórios rastreáveis para PR, QA, Sonar e CI.

A11yContractKit helps teams detect, document, and prevent common mobile accessibility issues aligned with WCAG principles. It does not replace manual accessibility testing, assistive technology testing, or formal compliance audits.

## Problem

Mobile teams often receive designs without complete accessibility specifications:

- Icons without accessible names
- Visual-only buttons
- Color-only states
- Unvalidated contrast
- Fixed fonts without Dynamic Type
- Missing `accessibilityLabel`, `accessibilityHint`, `accessibilityValue`, or traits
- No documentation for VoiceOver announcements

Console warnings are hard to track in PRs, CI, and SonarQube. A11yContractKit turns accessibility into **verifiable component contracts** with automated validation and traceable reports.

## Installation (SPM)

```swift
dependencies: [
    .package(url: "https://github.com/giovaninb/a11y-contract-kit.git", from: "0.1.0"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "A11yContractCore", package: "a11y-contract-kit"),
            .product(name: "A11yContractUIKit", package: "a11y-contract-kit"),
            .product(name: "A11yContractTesting", package: "a11y-contract-kit"),
        ]
    ),
]
```

**Requirements:** iOS 15+

## UIKit Example

```swift
import A11yContractCore
import A11yContractUIKit

let spec = A11ySpec(
    id: "delete_button",
    label: "Excluir item",
    hint: "Remove este item da lista",
    role: .button,
    wcag: [.nameRoleValue, .targetSize]
)

deleteButton.applyA11y(spec)

let result = A11yAudit.validate(view: deleteButton, spec: spec)
```

Fluent API:

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

## SwiftUI Example

```swift
import A11yContractSwiftUI

Button(action: delete) {
    Image(systemName: "trash")
}
.a11yContract(
    A11ySpec(
        id: "delete_button",
        label: "Excluir item",
        hint: "Remove este item da lista",
        role: .button
    )
)
```

## XCTest Example

```swift
import A11yContractTesting

func testDemoScreenAccessibility() throws {
    let report = A11yAudit.run(on: DemoViewController())
    XCTAssertNoCriticalA11yIssues(report)
}
```

## CLI Example

```bash
swift build -c release

.build/release/a11y-contract scan \
  --project . \
  --reporters markdown,sonar,sarif,junit \
  --output .a11y \
  --fail-on-new-issues \
  --baseline .a11y/baseline.json
```

Create baseline for legacy projects:

```bash
.build/release/a11y-contract baseline create \
  --project . \
  --output .a11y/baseline.json
```

## SonarQube Example

Add to `sonar-project.properties`:

```properties
sonar.externalIssuesReportPaths=.a11y/sonar-issues.json
```

See [Docs/en/SONAR_INTEGRATION.md](Docs/en/SONAR_INTEGRATION.md).

## GitHub Actions Example

See [.github/workflows/a11y-audit.yml](.github/workflows/a11y-audit.yml).

## Azure DevOps Example

See [Docs/en/CI_INTEGRATION.md](Docs/en/CI_INTEGRATION.md) (also available in [PT](Docs/pt/CI_INTEGRATION.md) and [ES](Docs/es/CI_INTEGRATION.md)).

## Demo App

App interativo em [`Examples/A11yContractDemo`](Examples/A11yContractDemo/):

```bash
cd Examples/A11yContractDemo
xcodegen generate
open A11yContractDemo.xcodeproj
```

Documentação em **inglês, português e espanhol** publicada em [GitHub Pages](https://giovaninb.github.io/a11y-contract-kit/) (`/`, `/pt/`, `/es/`).

## Modules

| Module | Description |
|--------|-------------|
| `A11yContractCore` | Models, rule engine, contrast, baseline |
| `A11yContractUIKit` | UIView extensions, scanner, fluent API |
| `A11yContractSwiftUI` | View modifier + registry |
| `A11yContractReporter` | Markdown, JSON, Sonar, SARIF, JUnit |
| `A11yContractTesting` | A11yAudit + XCTest helpers |
| `A11yContractCLI` | `a11y-contract` command-line tool |

## MVP Rules

1. Missing Accessibility Label (critical)
2. Missing Role / Trait (major)
3. Minimum Touch Target 44pt (major)
4. Low Contrast (critical)
5. Fixed Font Size / Dynamic Type (major)
6. Color-only State (major)
7. Missing Hint for Destructive Action (minor)

## Limitations

- Does not guarantee WCAG 2.1 AA compliance
- Contrast validation depends on extractable runtime colors
- SwiftUI has limited introspection; uses explicit modifiers + registry
- CLI runs accessibility audits via XCTest (runtime), not static source analysis
- `filePath` / `line` require declared `A11ySource` or registry metadata

## KMP Roadmap

Future Kotlin Multiplatform module:

```
a11y-contract-kmp/
├─ commonMain/   # A11ySpec, rules, contrast
├─ androidMain/  # Compose semantics adapters
└─ iosMain/      # Swift bridge / UIKit adapters
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
