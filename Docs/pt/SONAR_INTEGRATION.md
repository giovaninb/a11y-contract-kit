# Integração SonarQube

O A11yContractKit publica external issues compatíveis com o formato Generic Issue do SonarQube.

## Gerar relatório

```bash
.build/release/a11y-contract scan \
  --project . \
  --reporters sonar \
  --output .a11y
```

Arquivo de saída: `.a11y/sonar-issues.json`

## sonar-project.properties

```properties
sonar.externalIssuesReportPaths=.a11y/sonar-issues.json
```

## Exemplo de issue

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

## Recomendação para CI

1. Executar suite XCTest de acessibilidade
2. Gerar relatório Sonar com CLI
3. Enviar junto ao scan Sonar regular
4. Usar modo baseline para projetos legados
