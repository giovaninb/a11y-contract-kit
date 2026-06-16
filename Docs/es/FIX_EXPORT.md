# Exportación de correcciones (cherry-pick)

Tras la auditoría, `a11y-report.json` lista todos los hallazgos con `suggestedFix`. El flujo **export-fixes** permite **seleccionar** qué correcciones exportar y elegir el **estilo** de salida — similar a `git cherry-pick`, pero para correcciones de accesibilidad.

Esto **no** modifica `Sources/` automáticamente. Genera snippets listos para copiar y pegar.

## Cuándo usarlo

- El equipo usa **APIs UIKit nativas** y no puede adoptar el framework en toda la app
- Prefieres **modificadores SwiftUI** en lugar de `applyA11y`
- Quieres la **API fluida** de A11yContractKit (`A11yContract`)
- Solo necesitas corregir un **subconjunto** de hallazgos del último informe

## Estilos de corrección

| Estilo | Valor CLI | Salida |
|--------|-----------|--------|
| UIKit (nativo) | `uikit` | `accessibilityLabel`, traits, constraints Auto Layout |
| Framework | `framework` | `applyA11y` / API fluida `A11yContract` |
| SwiftUI | `swiftui` | `.a11yContract` o modificadores SwiftUI nativos |

## Flujo

**Aprende con el example mínimo:** [`Examples/UIKitExample`](../../Examples/UIKitExample/) en este repositorio.

### 1. Ejecutar scan

```bash
a11y-contract scan --project . --output .a11y --reporters markdown,json
```

### 2. Generar plantilla de selección

```bash
a11y-contract export-fixes init \
  --report .a11y/a11y-report.json \
  --output .a11y/a11y-fix-selection.json
```

La plantilla lista todos los issues con `"selected": false`. Edita el archivo:

- Marca `"selected": true` en los hallazgos deseados
- Elige `"style"`: `uikit`, `framework` o `swiftui`
- Opcionalmente `"groupByComponent": false` para un snippet por issue

### 3. Exportar bundle de correcciones

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --selection .a11y/a11y-fix-selection.json \
  --output .a11y
```

Crea `.a11y/a11y-fixes.md` por defecto.

### Atajo (sin manifest)

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --issues "<issue-id-1>,<issue-id-2>" \
  --style uikit \
  --output .a11y
```

Los IDs vienen de `a11y-report.json` (`issues[].id`).

## Opciones

| Flag | Descripción |
|------|-------------|
| `--format markdown` | Genera `a11y-fixes.md` (predeterminado) |
| `--format swift` | Genera `a11y-fixes.swift` con comentarios de contexto |
| `--no-group-by-component` | Un snippet por issue en lugar de agrupar por `componentId` |

## Ejemplo: mismo componente, tres estilos

Para `delete_button` sin label ni role:

```swift
// uikit
deleteButton.accessibilityIdentifier = "delete_button"
deleteButton.accessibilityLabel = "Descriptive label"
deleteButton.accessibilityTraits = [.button]

// framework
deleteButton.applyA11y(A11ySpec(
    id: "delete_button",
    label: "Descriptive label",
    role: .button,
    wcag: [.nameRoleValue],
))

// swiftui
deleteButton
    .a11yContract(A11ySpec(
        id: "delete_button",
        label: "Descriptive label",
        role: .button
    ))
```

## Qué no está incluido (MVP)

| Capacidad | Estado |
|-----------|--------|
| Exportar correcciones seleccionadas | Sí |
| Múltiples estilos de salida | Sí |
| Parche automático de código (`a11y-contract fix`) | No |
| Exportación de fixes en SARIF / Sonar | No |

Después de pegar los snippets, vuelve a ejecutar los tests y confirma con `XCTAssertNoCriticalA11yIssues`. La app **A11yContractDemo** (pestaña UIKit → **Corregido**) muestra el resultado visual esperado.
