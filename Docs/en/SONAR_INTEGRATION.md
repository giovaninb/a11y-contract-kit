# SonarQube Integration

A11yContractKit can publish external issues compatible with SonarQube Generic Issue format.

## Generate report

```bash
.build/release/a11y-contract scan \
  --project . \
  --reporters sonar \
  --output .a11y
```

Output file: `.a11y/sonar-issues.json`

## sonar-project.properties

```properties
sonar.externalIssuesReportPaths=.a11y/sonar-issues.json
```

## Example issue

```json
{
  "issues": [
    {
      "engineId": "A11yContractKit",
      "ruleId": "ios-a11y-missing-label",
      "severity": "CRITICAL",
      "type": "CODE_SMELL",
      "primaryLocation": {
        "message": "Interactive component without accessible label.",
        "filePath": "Sources/Demo/FavoriteButton.swift",
        "textRange": {
          "startLine": 42,
          "endLine": 42
        }
      }
    }
  ]
}
```

## CI recommendation

1. Run accessibility XCTest suite
2. Generate Sonar report with CLI
3. Upload alongside regular Sonar scan
4. Use baseline mode for legacy projects
