# CI Integration

## GitHub Actions

See [.github/workflows/a11y-audit.yml](https://github.com/giovaninb/a11y-contract-kit/blob/main/.github/workflows/a11y-audit.yml).

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

## iOS Simulator tests

For full UIKit runtime audits:

```bash
xcodebuild test \
  -scheme A11yContractKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

## Baseline workflow

1. `a11y-contract baseline create --project . --output .a11y/baseline.json`
2. Commit baseline to repository
3. CI uses `--fail-on-new-issues` to block only new violations

## Environment variables

| Variable | Description |
|----------|-------------|
| `A11Y_REPORT_OUTPUT` | Directory for per-test JSON reports (used by CLI aggregation) |
