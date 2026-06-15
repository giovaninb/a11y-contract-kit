# Handoff de design

Use o A11yContractKit para transformar entregas de design em contratos de componente verificáveis.

## Campos mínimos do contrato

| Campo | Owner | Obrigatório para componentes interativos |
|-------|-------|------------------------------------------|
| `id` | Development | Sim |
| `label` | Design | Sim |
| `hint` | Design | Para ações complexas/destrutivas |
| `role` | Design + Dev | Sim |
| `value` | Design | Para componentes com estado |
| `wcag` | Design + QA | Recomendado |

## Checklist de handoff

- [ ] Anúncio VoiceOver documentado por componente
- [ ] Touch target >= 44x44 pt
- [ ] Contraste validado para texto e ícones
- [ ] Estados não dependem só de cor
- [ ] Comportamento de Dynamic Type definido
- [ ] Ações destrutivas incluem hint de impacto

## Exemplo de nota de handoff

```text
Component: delete_button
Role: button
Label: Excluir item
Hint: Remove este item permanentemente
WCAG: 4.1.2, 2.5.5
Owner: Design
```

## Exportação Figma / ferramenta de design

Mapeie tokens e notas de componente para campos de `A11ySpec` na documentação do Design System.
