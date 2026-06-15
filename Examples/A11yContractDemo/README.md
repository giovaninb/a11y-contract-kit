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
| **Problemas** | Cartões por componente com ID, regra esperada e severidade |
| **Corrigido** | Mesmos componentes com contratos `applyA11y` e resumo do que foi aplicado |
| **SwiftUI** | Mesmo cenário UIKit (segmento Problemas / Corrigido) com `.a11yContract` |
| **Auditoria** | Scanner UIKit na tela Problemas; toque em um achado para detalhes |

## Idiomas

O app segue o idioma do simulador/dispositivo:

- **Português (pt-BR)** — padrão para usuários no Brasil
- **English (en)** — quando o sistema está em inglês

Abas, textos das telas e mensagens da auditoria usam o mesmo idioma.

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
