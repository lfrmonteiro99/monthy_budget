# Coach: Usar dados reais + diferenciar análise por tier

## Problema

O AI Coach financeiro gera respostas com exemplos hipotéticos ("se tens um curso de 300€", "se pagas 150€") em vez de usar os dados reais do utilizador. Isto acontece porque:

1. **Despesas enviadas apenas agregadas por categoria** — o prompt envia "Educação: 996.00€" mas nunca lista os items individuais (ex: "Mestrado ISCTE: 500€"). O modelo é forçado a inventar nomes e valores.
2. **Compras individuais não incluídas no prompt** — cada `PurchaseRecord` tem `items`, `amount` e `date`, mas o prompt só mostra totais e médias.
3. **System prompt insuficiente** — diz "usa números concretos" mas sem dados granulares, o modelo recorre a hipotéticos.
4. **Zero diferenciação entre Premium e Family** — ambos os tiers recebem o mesmo modelo, prompt e tokens. O Family (€6.99) não tem vantagem sobre o Premium (€3.99) no coach.

## Solução proposta

Ver plano detalhado: `docs/plans/2026-03-12-coach-real-data-tier-differentiation.md`

### Fase 1 — Dados reais no prompt (core fix)
- [ ] Listar despesas individuais nomeadas por categoria em `_buildPrompt`
- [ ] Incluir top 10 compras com data, valor e items no prompt
- [ ] Reforçar system prompt: proibir explicitamente exemplos hipotéticos

### Fase 2 — Diferenciação por tier
- [ ] **Free/Trial**: Análise básica (apenas totais, max 600 tokens, limite 3 análises)
- [ ] **Premium**: Análise estrutural (categorias agrupadas, 1000 tokens, 3 partes)
- [ ] **Family**: Análise detalhada (items individuais + compras, 1500 tokens, 4 partes com micro-optimizações)

### Fase 3 — UI por tier
- [ ] Passar `SubscriptionTier` ao `AiCoachService.analyze()`
- [ ] Badge visual por tier no card de resultado
- [ ] CTA de upgrade para tiers inferiores

### Fase 4 — Mid-month alert
- [ ] Aplicar mesma diferenciação ao alerta de meio do mês

## Ficheiros afectados

| Ficheiro | Alteração |
|----------|-----------|
| `lib/services/ai_coach_service.dart` | `_buildPrompt` com detalhe individual, `analyze` com tier, system prompt |
| `lib/screens/coach_screen.dart` | Passar tier, UI diferenciada |

## Impacto esperado
- **Custo API**: +20-30% tokens no Family (mais dados no prompt)
- **Qualidade**: Respostas com nomes reais de despesas em vez de hipotéticos
- **Conversão**: Upgrade path claro Free→Premium→Family no coach

## Labels
`enhancement`, `ai-coach`, `priority:high`
