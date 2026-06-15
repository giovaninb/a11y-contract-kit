# Exportação de correções (cherry-pick)

Após a auditoria, `a11y-report.json` lista todos os achados com `suggestedFix`. O fluxo **export-fixes** permite **selecionar** quais correções exportar e escolher o **estilo** de saída — parecido com `git cherry-pick`, mas para correções de acessibilidade.

Isso **não** altera `Sources/` automaticamente. Gera snippets prontos para copiar e colar.

## Quando usar

- O time usa **APIs UIKit nativas** e não pode adotar o framework em todo o app
- Você prefere **modificadores SwiftUI** em vez de `applyA11y`
- Quer a **API fluente** do A11yContractKit (`A11yContract`)
- Só precisa corrigir um **subconjunto** dos achados do último relatório

## Estilos de correção

| Estilo | Valor CLI | Saída |
|--------|-----------|-------|
| UIKit (nativo) | `uikit` | `accessibilityLabel`, traits, constraints Auto Layout |
| Framework | `framework` | `applyA11y` / API fluente `A11yContract` |
| SwiftUI | `swiftui` | `.a11yContract` ou modificadores SwiftUI nativos |

## Fluxo

### 1. Rodar scan

```bash
a11y-contract scan --project . --output .a11y --reporters markdown,json
```

### 2. Gerar template de seleção

```bash
a11y-contract export-fixes init \
  --report .a11y/a11y-report.json \
  --output .a11y/a11y-fix-selection.json
```

O template lista todos os issues com `"selected": false`. Edite o arquivo:

- Marque `"selected": true` nos achados desejados
- Escolha `"style"`: `uikit`, `framework` ou `swiftui`
- Opcionalmente `"groupByComponent": false` para um snippet por issue

### 3. Exportar bundle de correções

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --selection .a11y/a11y-fix-selection.json \
  --output .a11y
```

Cria `.a11y/a11y-fixes.md` por padrão.

### Atalho (sem manifest)

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --issues "<issue-id-1>,<issue-id-2>" \
  --style uikit \
  --output .a11y
```

Os IDs vêm de `a11y-report.json` (`issues[].id`).

## Opções

| Flag | Descrição |
|------|-----------|
| `--format markdown` | Gera `a11y-fixes.md` (padrão) |
| `--format swift` | Gera `a11y-fixes.swift` com comentários de contexto |
| `--no-group-by-component` | Um snippet por issue em vez de agrupar por `componentId` |

## Exemplo: mesmo componente, três estilos

Para `delete_button` sem label e role:

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

## O que não está incluído (MVP)

| Capacidade | Status |
|------------|--------|
| Exportar correções selecionadas | Sim |
| Múltiplos estilos de saída | Sim |
| Patch automático de código (`a11y-contract fix`) | Não |
| Exportação de fixes em SARIF / Sonar | Não |

Depois de colar os snippets, re-rode os testes e confirme com `XCTAssertNoCriticalA11yIssues`. O app **A11yContractDemo** (aba UIKit → **Corrigido**) mostra o resultado visual esperado.
