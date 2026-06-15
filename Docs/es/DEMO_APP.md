# A11yContractDemo

App de demostración de **A11yContractKit** con ejemplos UIKit, SwiftUI y auditoría en tiempo real.

## Abrir en Xcode

```bash
cd Examples/A11yContractDemo
xcodegen generate   # si falta el .xcodeproj
open A11yContractDemo.xcodeproj
```

El repositorio incluye el `A11yContractDemo.xcodeproj` generado.

## Ejecutar

1. Seleccione el scheme **A11yContractDemo**
2. Elija un simulador iOS 15+
3. Run (⌘R)

## Pestañas del app

| Pestaña | Descripción |
|---------|-------------|
| **Problemas** | Botones sin label, touch target pequeño, contraste bajo |
| **Corregido** | Mismos componentes con `applyA11y` |
| **SwiftUI** | Modifier `.a11yContract` |
| **Auditoría** | Ejecuta scanner UIKit y lista issues |

## Tests

```bash
xcodebuild test \
  -project A11yContractDemo.xcodeproj \
  -scheme A11yContractDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

O en Xcode: ⌘U

## Dependencia local

El demo referencia el paquete A11yContractKit en `../../` (raíz del repositorio).
