# Exportação de correções (cherry-pick)

Após a auditoria, `a11y-report.json` lista todos os achados com `suggestedFix`. O fluxo **export-fixes** permite **selecionar** quais correções exportar, escolher o **estilo** de saída e **aplicar patches** nos arquivos Swift.

## Origem obrigatória no scan

Todo achado no relatório precisa de **arquivo + linha** para ser corrigível. Configure:

1. **`A11yAuditable`** na `UIViewController` — declara o arquivo Swift da tela
2. **`accessibilityIdentifier`** em cada componente interativo
3. Opcional: **`A11yContractRegistry.registerSource(...)`** para linha exata

Achados sem origem **não aparecem** no relatório.

## Atalho com Makefile

Na raiz do repositório:

```bash
make scan          # audita o projeto (gera .a11y/a11y-report.json)
make html          # relatório visual para revisar achados por arquivo
make patch-all     # corrige TODOS os achados com arquivo de origem (rápido)
make fix           # scan + patch-all + verify
```

Tutorial UIKitExample:

```bash
make uikit-demo              # build + scan + HTML + abrir (localhost)
# no HTML: estilo + achados → Salvar seleção → pasta Examples/UIKitExample/.a11y
make uikit-patch             # aplica a seleção salva (lê a11y-fix-selection.json)
make uikit-verify            # re-scan
make uikit-reset             # recomeçar o example
```

Se o JSON foi para **Downloads** (abriu o HTML como `file://`):

```bash
make uikit-import-selection  # copia ~/Downloads → .a11y
make uikit-patch
```

Para projetos grandes (dezenas de arquivos): selecione estilo e achados no HTML, clique **Salvar seleção** (grava `a11y-fix-selection.json` na pasta `.a11y`) e rode **`make patch-all`** — sem copiar comandos.

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
| SwiftUI | `swiftui` | Modificadores SwiftUI nativos |

## Fluxo

**Aprenda com o example mínimo:** [`Examples/UIKitExample`](../../Examples/UIKitExample/) neste repositório.

### 1. Rodar scan

```bash
a11y-contract scan --project . --output .a11y --reporters markdown,json
```

### 2. Relatório visual (HTML)

```bash
a11y-contract export-fixes view \
  --report .a11y/a11y-report.json \
  --output .a11y \
  --project .

open .a11y/a11y-report.html
```

A página HTML agrupa achados por arquivo e mostra snippets por estilo. Clique **Salvar seleção** para gravar `a11y-fix-selection.json` na pasta `.a11y` (na primeira vez, escolha essa pasta no diálogo).

### 3. Aplicar correções nos arquivos

**Com seleção do HTML (recomendado):**

```bash
make patch-all
# lê .a11y/a11y-fix-selection.json automaticamente (estilo + achados selecionados)
```

**Todos os achados com arquivo (sem HTML):**

```bash
a11y-contract export-fixes patch \
  --report .a11y/a11y-report.json \
  --all \
  --project . \
  --style framework
```

**Subconjunto por issue ID:**

```bash
a11y-contract export-fixes patch \
  --report .a11y/a11y-report.json \
  --issues "<issue-id-1>,<issue-id-2>" \
  --project . \
  --style framework
```

Use `--dry-run` para pré-visualizar sem gravar. `--open` abre no editor apenas se ≤5 arquivos mudaram.

### 4. Exportar snippets (sem patch)

```bash
a11y-contract export-fixes init --report .a11y/a11y-report.json --output .a11y/a11y-fix-selection.json
# editar JSON: "selected": true, "style": "uikit"

a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --selection .a11y/a11y-fix-selection.json \
  --output .a11y
```

## Opções

| Flag | Descrição |
|------|-----------|
| `export-fixes patch` | Grava correções em `Sources/` |
| `--all` | Corrige todos os achados com arquivo de origem |
| `--dry-run` | Mostra mudanças sem gravar |
| `--open` | Abre arquivos patchados no editor |
| `--format markdown` | Gera `a11y-fixes.md` (export apply) |
| `--no-group-by-component` | Um snippet por issue |

## Capacidades (v1.1)

| Capacidade | Status |
|------------|--------|
| Exportar correções selecionadas | Sim |
| HTML interativo com agrupamento por arquivo | Sim |
| Patch automático (`export-fixes patch`) | Sim |
| Origem obrigatória no scan | Sim |
| Exportação de fixes em SARIF / Sonar | Não |

Depois de corrigir, re-rode o scan e confirme com `XCTAssertNoCriticalA11yIssues`.
