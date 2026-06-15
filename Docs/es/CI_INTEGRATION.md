# Integración CI

## GitHub Actions

Ver [.github/workflows/a11y-audit.yml](https://github.com/giovaninb/a11y-contract-kit/blob/main/.github/workflows/a11y-audit.yml).

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

## Tests en simulador iOS

Para auditorías UIKit completas en runtime:

```bash
xcodebuild test \
  -scheme A11yContractKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

## Flujo de baseline

1. `a11y-contract baseline create --project . --output .a11y/baseline.json`
2. Commit del baseline en el repositorio
3. CI usa `--fail-on-new-issues` para fallar solo en violaciones nuevas

## Variables de entorno

| Variable | Descripción |
|----------|-------------|
| `A11Y_REPORT_OUTPUT` | Directorio para reportes JSON parciales por test (agregación CLI) |
