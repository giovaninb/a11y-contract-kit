# Integração CI

## GitHub Actions

Veja [.github/workflows/a11y-audit.yml](https://github.com/giovaninb/a11y-contract-kit/blob/main/.github/workflows/a11y-audit.yml).

```yaml
name: Accessibility Audit

on:
  pull_request:
    branches: [ main ]

jobs:
  a11y:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build A11yContract CLI
        run: swift build -c release

      - name: Run Accessibility Scan
        run: |
          .build/release/a11y-contract scan \
            --project . \
            --reporters markdown,sonar,sarif,junit \
            --output .a11y \
            --fail-on-new-issues \
            --baseline .a11y/baseline.json

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: .a11y/a11y.sarif

      - name: Upload Reports
        uses: actions/upload-artifact@v4
        with:
          name: a11y-reports
          path: .a11y
```

## Azure DevOps

```yaml
trigger:
  - main

pool:
  vmImage: 'macos-latest'

steps:
  - script: swift build -c release
    displayName: Build A11yContract CLI

  - script: |
      .build/release/a11y-contract scan \
        --project . \
        --reporters markdown,sonar,junit \
        --output .a11y \
        --fail-on-new-issues \
        --baseline .a11y/baseline.json
    displayName: Run Accessibility Scan

  - task: PublishTestResults@2
    inputs:
      testResultsFormat: 'JUnit'
      testResultsFiles: '.a11y/a11y-junit.xml'
```

## Testes no simulador iOS

Para auditorias UIKit completas em runtime:

```bash
xcodebuild test \
  -scheme A11yContractKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

## Fluxo de baseline

1. `a11y-contract baseline create --project . --output .a11y/baseline.json`
2. Commit do baseline no repositório
3. CI usa `--fail-on-new-issues` para falhar apenas em violações novas

## Variáveis de ambiente

| Variável | Descrição |
|----------|-----------|
| `A11Y_REPORT_OUTPUT` | Diretório para relatórios JSON parciais por teste (agregação CLI) |
