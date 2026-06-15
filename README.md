<p align="center">
  <img src="Docs/assets/logo.png" alt="A11yContractKit logo" width="480">
</p>

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
    .package(url: "https://github.com/giovaninb/a11y-contract-kit.git", from: "1.0.0"),
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

## Installation (CocoaPods)

Veja [`A11yContractKit.podspec`](A11yContractKit.podspec). Exemplo mínimo:

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'A11yContractKit/UIKit', '~> 1.0'
end

target 'YourAppTests' do
  pod 'A11yContractKit/Testing', '~> 1.0'
end
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

### Abas do demo

| Aba | O que mostra |
|-----|----------------|
| **UIKit** | Segmento **Problemas \| Corrigido** — cartões por componente, regras esperadas e `applyA11y` |
| **Custom** | Ordem de leitura VoiceOver (header → labels → Continuar) com `accessibilityElements` |
| **SwiftUI** | Mesmo cenário com `.a11yContract` |
| **Auditoria** | Scanner na tela UIKit → Problemas; toque em um achado para ver detalhes e `suggestedFix` |

```bash
cd Examples/A11yContractDemo
xcodegen generate
open A11yContractDemo.xcodeproj
```

## Auditar um módulo local (Sources + Sample + Tests)

A11yContractKit **não faz análise estática de `Sources/`**. A auditoria é **runtime**: você instancia telas/componentes (via **Sample** ou factories de teste) e roda `A11yAudit` nos **Tests**.

```
SeuModulo/
├── Sources/          # código da lib — melhorado com contratos applyA11y / .a11yContract
├── Sample/           # telas de exemplo para montar e auditar
└── Tests/            # XCTest + A11yAudit + exportação de relatório
```

### 1. Dependências

**Swift Package (recomendado):**

```swift
dependencies: [
    .package(url: "https://github.com/giovaninb/a11y-contract-kit.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "SeuModulo",
        dependencies: [
            .product(name: "A11yContractUIKit", package: "a11y-contract-kit"),
        ]
    ),
    .testTarget(
        name: "SeuModuloTests",
        dependencies: [
            "SeuModulo",
            .product(name: "A11yContractTesting", package: "a11y-contract-kit"),
            .product(name: "A11yContractReporter", package: "a11y-contract-kit"),
        ]
    ),
]
```

**CocoaPods (Podfile):**

```ruby
platform :ios, '15.0'

target 'SeuModulo' do
  # Contratos + scanner UIKit + reporters
  pod 'A11yContractKit/UIKit', '~> 1.0'
  pod 'A11yContractKit/Reporter', '~> 1.0'
  # pod 'A11yContractKit/SwiftUI', '~> 1.0'  # se usar SwiftUI
end

target 'SeuModuloSample' do
  pod 'A11yContractKit/UIKit', '~> 1.0'
end

target 'SeuModuloTests' do
  inherit! :search_paths
  pod 'A11yContractKit/Testing', '~> 1.0'
end
```

**Kit local (desenvolvimento):**

```ruby
pod 'A11yContractKit/Testing', :path => '../a11y-contract-kit'
```

**Git remoto:**

```ruby
pod 'A11yContractKit/Testing', :git => 'https://github.com/giovaninb/a11y-contract-kit.git', :tag => '1.0.0'
```

Subspecs disponíveis (espelham `Sources/`):

| Subspec | Módulo Swift | Uso |
|---------|--------------|-----|
| `Core` | `A11yContractCore` | Models, rules, baseline |
| `Reporter` | `A11yContractReporter` | Markdown, JSON, Sonar, SARIF, JUnit |
| `UIKit` | `A11yContractUIKit` | `applyA11y`, scanner, fluent API |
| `SwiftUI` | `A11yContractSwiftUI` | `.a11yContract` |
| `Testing` | `A11yContractTesting` | `A11yAudit`, helpers XCTest (**só target de teste**) |

Depois: `pod install`. A CLI `a11y-contract` continua via SPM (`swift build` no clone do kit) — não está no pod iOS.

### 2. Teste de auditoria (Sample → relatório)

Crie testes cujo nome contenha `A11y` (filtro padrão da CLI):

```swift
import XCTest
import A11yContractTesting
import A11yContractReporter
@testable import SeuModulo

final class SeuModuloAccessibilityTests: XCTestCase {
    override func tearDown() {
        A11yContractRegistry.shared.clear()
        super.tearDown()
    }

    func testSampleMainScreenA11y() throws {
        let report = A11yAudit.run(
            on: SampleMainViewController(),   // tela do Sample que usa Sources
            projectName: "SeuModulo"
        )

        // Falha o teste se houver críticos (opcional, para CI)
        XCTAssertNoCriticalA11yIssues(report)

        // Exporta JSON parcial para a CLI agregar (quando A11Y_REPORT_OUTPUT estiver setado)
        try A11yTestReportExporter.exportIfNeeded(report, testName: name)

        // Dev local: gere Markdown e veja o plano de melhoria
        let markdown = try MarkdownA11yReporter().generate(report: report)
        print(markdown) // ou grave em .a11y/a11y-report.md
    }
}
```

Rode no simulador iOS:

```bash
xcodebuild test \
  -scheme SeuModulo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:SeuModuloTests/SeuModuloAccessibilityTests
```

### 3. Relatório consolidado (CLI)

Clone o kit, build a CLI, e aponte para o pacote (funciona melhor quando o módulo é um **Swift Package** na raiz):

```bash
git clone https://github.com/giovaninb/a11y-contract-kit.git
cd a11y-contract-kit && swift build -c release

cd /caminho/para/SeuModulo
A11Y_REPORT_OUTPUT=.a11y/partial \
  /caminho/para/a11y-contract-kit/.build/release/a11y-contract scan \
    --project . \
    --reporters markdown,json,sonar,sarif,junit \
    --output .a11y \
    --fail-on critical
```

Arquivos gerados em `.a11y/`:

| Arquivo | Uso |
|---------|-----|
| `a11y-report.md` | Plano legível: severidade, componente, WCAG, **suggested fix** |
| `a11y-report.json` | Automação / dashboards |
| `a11y.sarif` | GitHub Code Scanning |
| `sonar-issues.json` | SonarQube |
| `a11y-junit.xml` | CI / Azure DevOps |

Para legado, crie baseline e falhe só em issues novas:

```bash
a11y-contract baseline create --project . --output .a11y/baseline.json
a11y-contract scan --project . --output .a11y --fail-on-new-issues --baseline .a11y/baseline.json
```

### 4. “Aplicar correção” — o que existe hoje

| Capacidade | Status |
|------------|--------|
| Detectar problemas (`A11yAudit`, scanner UIKit) | ✅ |
| Relatório com `suggestedFix` (snippet Swift) | ✅ |
| Exportar correções selecionadas (cherry-pick) | ✅ |
| Aplicar contrato manualmente (`applyA11y`, `.a11yContract`) | ✅ |
| Patch automático de `Sources/` (`a11y-contract fix`) | ❌ **não existe no MVP** |

Cada issue no relatório traz uma **correção sugerida** — por exemplo:

```swift
view.applyA11y(A11ySpec(
    id: "delete_button",
    label: "Descriptive label",
    role: .button
))
```

Você copia/adapta o snippet em `Sources/`, re-roda os testes e confirma no relatório. A aba **Corrigido** do demo mostra exatamente esse padrão (contrato explícito por componente).

Para ordem de leitura VoiceOver (header → labels → botão), a correção continua manual via `accessibilityElements` — veja a aba **Custom → Corrigido** no demo.

#### Cherry-pick de correções (`export-fixes`)

Como `git cherry-pick` escolhe commits, você pode selecionar **quais achados** exportar e em **qual estilo** — útil quando o time não usa o framework em todo o app:

| Estilo | Saída típica |
|--------|--------------|
| `uikit` | APIs nativas (`accessibilityLabel`, traits, constraints) |
| `framework` | `applyA11y` / `A11yContract` fluent |
| `swiftui` | `.a11yContract` ou modificadores SwiftUI nativos |

```bash
# 1. Scan normal
a11y-contract scan --project . --output .a11y

# 2. Gerar template de seleção
a11y-contract export-fixes init \
  --report .a11y/a11y-report.json \
  --output .a11y/a11y-fix-selection.json

# 3. Editar JSON: marcar "selected": true nos issues desejados + escolher "style"

# 4. Exportar bundle pronto para copiar
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --selection .a11y/a11y-fix-selection.json \
  --output .a11y
```

Atalho sem manifest:

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --issues "<issue-id-1>,<issue-id-2>" \
  --style uikit \
  --output .a11y
```

Gera `.a11y/a11y-fixes.md` (ou `.swift` com `--format swift`). **Não modifica `Sources/`** — cole manualmente e re-rode os testes.

Exemplo para o mesmo `delete_button`:

```swift
// uikit
deleteButton.accessibilityLabel = "Descriptive label"
deleteButton.accessibilityTraits = [.button]

// framework
deleteButton.applyA11y(A11ySpec(id: "delete_button", label: "Descriptive label", role: .button))

// swiftui
deleteButton
    .a11yContract(A11ySpec(id: "delete_button", label: "Descriptive label", role: .button))
```

### Fluxo sugerido para amanhã

1. Adicionar `A11yContractTesting` no target **Tests** (SPM no workspace com Podfile).
2. Criar `Sample/*A11y*` ou reutilizar telas do Sample nos testes.
3. Escrever `test*Tela*A11y()` com `A11yAudit.run(on:)`.
4. Rodar testes no simulador → ler `.a11y/a11y-report.md`.
5. `export-fixes init` → selecionar achados → `export-fixes apply` no estilo UIKit, Framework ou SwiftUI.
6. Colar snippets em `Sources/`, re-rodar testes até `XCTAssertNoCriticalA11yIssues` passar.

## Modules

| Module | Description |
|--------|-------------|
| `A11yContractCore` | Models, rule engine, contrast, baseline |
| `A11yContractUIKit` | UIView extensions, scanner, fluent API |
| `A11yContractSwiftUI` | View modifier + registry |
| `A11yContractReporter` | Markdown, JSON, Sonar, SARIF, JUnit, fix cherry-pick export |
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
