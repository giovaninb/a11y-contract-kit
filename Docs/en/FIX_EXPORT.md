# Fix export (cherry-pick)

After an audit, `a11y-report.json` lists every issue with a `suggestedFix`. The **export-fixes** flow lets you **select** which fixes to export and choose an output **style** — similar to `git cherry-pick`, but for accessibility corrections.

This does **not** patch your `Sources/` automatically. It generates snippets ready to copy and paste.

## When to use it

- Your team uses **UIKit APIs** directly and cannot adopt the framework everywhere
- You want **SwiftUI modifiers** instead of `applyA11y`
- You prefer the **A11yContractKit fluent API** (`A11yContract`)
- You only want to fix a **subset** of findings from the latest report

## Fix styles

| Style | CLI value | Output |
|-------|-----------|--------|
| UIKit (native) | `uikit` | `accessibilityLabel`, traits, Auto Layout constraints |
| Framework | `framework` | `applyA11y` / `A11yContract` fluent API |
| SwiftUI | `swiftui` | `.a11yContract` or native SwiftUI accessibility modifiers |

## Workflow

### 1. Run a scan

```bash
a11y-contract scan --project . --output .a11y --reporters markdown,json
```

### 2. Generate a selection template

```bash
a11y-contract export-fixes init \
  --report .a11y/a11y-report.json \
  --output .a11y/a11y-fix-selection.json
```

The template lists every issue with `"selected": false`. Edit the file:

- Set `"selected": true` on issues you want to export
- Choose `"style"`: `uikit`, `framework`, or `swiftui`
- Optionally set `"groupByComponent": false` to export one snippet per issue

### 3. Export the fix bundle

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --selection .a11y/a11y-fix-selection.json \
  --output .a11y
```

Creates `.a11y/a11y-fixes.md` by default.

### Shortcut (no manifest)

```bash
a11y-contract export-fixes apply \
  --report .a11y/a11y-report.json \
  --issues "<issue-id-1>,<issue-id-2>" \
  --style uikit \
  --output .a11y
```

Issue IDs come from `a11y-report.json` (`issues[].id`).

## Options

| Flag | Description |
|------|-------------|
| `--format markdown` | Write `a11y-fixes.md` (default) |
| `--format swift` | Write `a11y-fixes.swift` with comment headers |
| `--no-group-by-component` | One snippet per issue instead of merging by `componentId` |

## Example: same component, three styles

For `delete_button` missing label and role:

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

## What is not included (MVP)

| Capability | Status |
|------------|--------|
| Export selected fixes | Yes |
| Multiple output styles | Yes |
| Automatic patch of source files (`a11y-contract fix`) | No |
| SARIF / Sonar fix export | No |

After pasting snippets, re-run tests and confirm with `XCTAssertNoCriticalA11yIssues`. The **A11yContractDemo** app (UIKit → **Fixed** tab) shows the expected visual result.
