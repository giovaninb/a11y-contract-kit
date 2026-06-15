# Mapeamento WCAG

O A11yContractKit mapeia regras para critérios WCAG 2.x como orientação. Passar nessas verificações **não** significa conformidade WCAG.

| Rule ID | WCAG | Severidade |
|---------|------|------------|
| `ios-a11y-missing-label` | 1.1.1, 4.1.2 | critical |
| `ios-a11y-missing-role` | 4.1.2 | major |
| `ios-a11y-touch-target` | 2.5.5 | major |
| `ios-a11y-touch-target-wcag` | 2.5.8 | major |
| `ios-a11y-touch-target-hig` | — (Apple HIG) | info |
| `ios-a11y-low-contrast` | 1.4.3 | critical |
| `ios-a11y-fixed-font` | 1.4.4 | major |
| `ios-a11y-color-only-state` | 1.4.1 | major |
| `ios-a11y-missing-hint-destructive` | 4.1.2 | minor |

## Mapeamento iOS

| Campo A11ySpec | API iOS |
|----------------|---------|
| `label` | `accessibilityLabel` |
| `hint` | `accessibilityHint` |
| `value` | `accessibilityValue` |
| `role` | `accessibilityTraits` |
| `id` | `accessibilityIdentifier` |

## Critérios futuros

- 2.1.1 Keyboard
- 2.4.3 Focus Order
- 2.4.7 Focus Visible
