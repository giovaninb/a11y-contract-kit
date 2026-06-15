# A11yContractDemo

App de demonstração do **A11yContractKit** com exemplos UIKit, padrões customizados, SwiftUI e auditoria em tempo real.

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
| **UIKit** | Segmento Problemas / Corrigido com cartões e `applyA11y` |
| **Custom** | Ordem de leitura (header + labels + Continuar) — Problemas vs Corrigido |
| **SwiftUI** | Mesmo cenário UIKit com `.a11yContract` |
| **Auditoria** | Scanner na tela UIKit → Problemas; toque em um achado para detalhes |

Cada aba UIKit, Custom e SwiftUI usa o segmento **Problemas | Corrigido** no topo.

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
