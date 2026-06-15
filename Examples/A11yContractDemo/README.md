# A11yContractDemo

App de demonstração do **A11yContractKit** com exemplos UIKit, SwiftUI e auditoria em tempo real.

## Abrir no Xcode

```bash
cd Examples/A11yContractDemo
xcodegen generate   # se ainda não tiver o .xcodeproj
open A11yContractDemo.xcodeproj
```

Se não tiver [XcodeGen](https://github.com/yonaskolb/XcodeGen) instalado, o repositório inclui o `A11yContractDemo.xcodeproj` gerado.

## Executar

1. Selecione o scheme **A11yContractDemo**
2. Escolha um simulador iOS 15+
3. Run (⌘R)

## Abas do app

| Aba | Descrição |
|-----|-----------|
| **Problemas** | Botões sem label, touch target pequeno, contraste baixo |
| **Corrigido** | Mesmos componentes com `applyA11y` |
| **SwiftUI** | Modifier `.a11yContract` |
| **Auditoria** | Roda `A11yAudit` e lista issues |

## Testes

```bash
xcodebuild test \
  -project A11yContractDemo.xcodeproj \
  -scheme A11yContractDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

Ou via Xcode: ⌘U

## Dependência local

O demo referencia o pacote A11yContractKit em `../../` (raiz do repositório).
