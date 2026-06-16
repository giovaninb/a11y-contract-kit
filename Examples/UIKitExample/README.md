# UIKitExample — Cherry-pick de correções

Example mínimo para aprender o fluxo **export-fixes**: auditar um botão UIKit problemático, selecionar achados e exportar snippets em **UIKit**, **Framework** ou **SwiftUI**.

Não é um app Xcode — roda via **Swift Package Manager** na raiz do repositório.

## Atalho com Makefile

Na **raiz** do repositório:

```bash
make help                    # ver todos os comandos
make uikit-demo              # build + scan + HTML + abrir (localhost)
# no HTML: estilo + achados → Salvar seleção → pasta Examples/UIKitExample/.a11y
make uikit-patch             # aplica a seleção salva (lê a11y-fix-selection.json)
make uikit-verify            # re-scan e resumo dos achados
make uikit-reset             # volta ao estado inicial e reabre o HTML
```

Se **Salvar seleção** baixou o JSON em Downloads:

```bash
make uikit-import-selection  # copia para Examples/UIKitExample/.a11y
make uikit-patch
```

Variáveis úteis: `UIKIT_STYLE=uikit|framework|swiftui` (fallback sem JSON salvo), `LANG=pt|en|es`, `DESTINATION='platform=iOS Simulator,...'`.

## O que contém

| Arquivo | Papel |
|---------|-------|
| `DeleteButtonProblemsViewController` | `delete_button` sem label, sem role, alvo 28×28 pt |
| `DeleteButtonFixedViewController` | Mesmo botão com `applyA11y` (referência da correção) |
| `DeleteButtonA11yTests` | Gera relatório parcial para a CLI |

## Pré-requisitos

- macOS com Xcode + simulador iOS (ex.: iPhone 16 com iOS 18.6)
- Repositório clonado na raiz

O `scan` usa **xcodebuild** no simulador iOS por padrão (`--platform ios`). Se o simulador padrão não existir na sua máquina, ajuste:

```bash
--destination 'platform=iOS Simulator,OS=17.5,name=iPhone 15'
```

## Passo a passo

### 1. Rodar auditoria

Na **raiz** do repositório:

```bash
swift build -c release

.build/release/a11y-contract scan \
  --project . \
  --filter UIKitExample \
  --reporters markdown,json \
  --output Examples/UIKitExample/.a11y
```

Isso gera:

- `Examples/UIKitExample/.a11y/a11y-report.json`
- `Examples/UIKitExample/.a11y/a11y-report.md`

### 2. Gerar template de seleção (cherry-pick)

```bash
.build/release/a11y-contract export-fixes init \
  --report Examples/UIKitExample/.a11y/a11y-report.json \
  --output Examples/UIKitExample/.a11y/a11y-fix-selection.json
```

Abra `a11y-fix-selection.json` e marque `"selected": true` nos issues de `delete_button`. Escolha o estilo:

```json
"style": "uikit"
```

Valores: `uikit` | `framework` | `swiftui`

### 3. Exportar bundle de correções

```bash
.build/release/a11y-contract export-fixes apply \
  --report Examples/UIKitExample/.a11y/a11y-report.json \
  --selection Examples/UIKitExample/.a11y/a11y-fix-selection.json \
  --output Examples/UIKitExample/.a11y
```

Saída: `a11y-fixes.md` com snippets prontos para copiar.

### 3b. Relatório visual (HTML)

```bash
.build/release/a11y-contract export-fixes view \
  --report Examples/UIKitExample/.a11y/a11y-report.json \
  --output Examples/UIKitExample/.a11y

open Examples/UIKitExample/.a11y/a11y-report.html
```

Prefira `make uikit-open` (serve via `http://localhost:8788`) para **Salvar seleção** gravar direto na pasta `.a11y`.

Ou gere direto no scan:

```bash
.build/release/a11y-contract scan \
  --project . \
  --filter UIKitExample \
  --reporters markdown,json,html \
  --output Examples/UIKitExample/.a11y
```

Na página HTML você pode:

- Ver cada achado com severidade e snippet por estilo
- Marcar quais correções aceitar (checkbox)
- Alternar estilo: **UIKit** | **Framework** | **SwiftUI**
- Clicar **Salvar seleção** para gravar `a11y-fix-selection.json` na pasta `.a11y`
- Depois rodar `make uikit-patch` (ou `make uikit-import-selection` se o JSON foi para Downloads)

### 4. Comparar estilos

Repita o passo 3 com estilos diferentes (edite `"style"` no JSON):

| Estilo | Quando usar |
|--------|-------------|
| `uikit` | Time sem dependência do framework — APIs nativas |
| `framework` | Projeto com A11yContractKit — `applyA11y` |
| `swiftui` | Tela em SwiftUI — `.a11yContract` ou modificadores nativos |

### 5. Validar a correção

Compare o snippet exportado com `DeleteButtonFixedViewController.swift` — é o resultado esperado com contrato aplicado.

Re-rode os testes:

```bash
swift test --filter UIKitExample
```

`testDeleteButtonFixedHasNoCriticalIssues` deve passar na tela corrigida.

## Atalho sem manifest

```bash
.build/release/a11y-contract export-fixes apply \
  --report Examples/UIKitExample/.a11y/a11y-report.json \
  --issues "<issue-id-do-json>" \
  --style framework \
  --output Examples/UIKitExample/.a11y
```

## Demo completo

Para exploração visual (abas UIKit / SwiftUI / Auditoria), use [`A11yContractDemo`](../A11yContractDemo/).

## Limitações

- Patch automático cobre regras comuns (label, role, touch target, `applyA11y`); revise no Xcode antes de commitar
- Achados só aparecem se tiverem `accessibilityIdentifier` + origem no código (`A11yAuditable` ou `registerSource`)
