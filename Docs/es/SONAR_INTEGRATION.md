# Integración SonarQube

A11yContractKit publica external issues compatibles con el formato Generic Issue de SonarQube.

## Generar reporte

```bash
.build/release/a11y-contract scan \
  --project . \
  --reporters sonar \
  --output .a11y
```

Archivo de salida: `.a11y/sonar-issues.json`

## sonar-project.properties

```properties
sonar.externalIssuesReportPaths=.a11y/sonar-issues.json
```

## Ejemplo de issue

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

## Recomendación para CI

1. Ejecutar suite XCTest de accesibilidad
2. Generar reporte Sonar con CLI
3. Subir junto al scan Sonar regular
4. Usar modo baseline para proyectos legacy
