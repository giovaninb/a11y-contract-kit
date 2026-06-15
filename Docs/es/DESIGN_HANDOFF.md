# Entrega de diseño

Use A11yContractKit para convertir entregables de diseño en contratos de componente verificables.

## Campos mínimos del contrato

| Campo | Owner | Obligatorio para componentes interactivos |
|-------|-------|-------------------------------------------|
| `id` | Development | Sí |
| `label` | Design | Sí |
| `hint` | Design | Para acciones complejas/destructivas |
| `role` | Design + Dev | Sí |
| `value` | Design | Para componentes con estado |
| `wcag` | Design + QA | Recomendado |

## Checklist de entrega

- [ ] Anuncio VoiceOver documentado por componente
- [ ] Touch target >= 44x44 pt
- [ ] Contraste validado para texto e íconos
- [ ] Estados no dependen solo del color
- [ ] Comportamiento de Dynamic Type definido
- [ ] Acciones destructivas incluyen hint de impacto

## Ejemplo de nota de entrega

```text
Component: delete_button
Role: button
Label: Eliminar elemento
Hint: Elimina este elemento permanentemente
WCAG: 4.1.2, 2.5.5
Owner: Design
```

## Exportación Figma / herramienta de diseño

Mapee tokens y notas de componente a campos de `A11ySpec` en la documentación del Design System.
