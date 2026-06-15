# Design Handoff

Use A11yContractKit to turn design deliverables into verifiable component contracts.

## Minimum contract fields

| Field | Owner | Required for interactive components |
|-------|-------|-------------------------------------|
| `id` | Development | Yes |
| `label` | Design | Yes |
| `hint` | Design | For complex/destructive actions |
| `role` | Design + Dev | Yes |
| `value` | Design | For stateful components |
| `wcag` | Design + QA | Recommended |

## Handoff checklist

- [ ] VoiceOver announcement documented per component
- [ ] Touch target >= 44x44 pt
- [ ] Contrast validated for text and icons
- [ ] States not conveyed by color alone
- [ ] Dynamic Type behavior defined
- [ ] Destructive actions include impact hint

## Example handoff note

```text
Component: delete_button
Role: button
Label: Delete item
Hint: Permanently removes this item
WCAG: 4.1.2, 2.5.5
Owner: Design
```

## Figma / design tool export

Map design tokens and component notes to `A11ySpec` fields in your Design System documentation.
