# Plano: Coach com Dados Reais + Diferenciação por Tier

## Diagnóstico Real (vs. análise original)

### Correcções importantes à análise
1. **Os tiers reais são Free/Premium(€3.99)/Family(€6.99)** — não Eco/Plus/Pro
2. **O coach NÃO é um chat/conversa** — é um botão "Analisar" que gera uma análise one-shot. Não há sistema de créditos, memória %, ou conversação. Cada clique = prompt novo.
3. **Não existe diferenciação de tier no coach** — Premium e Family recebem exactamente o mesmo: mesmo modelo (`gpt-4o-mini`), mesmo prompt, mesmos tokens (1000 max).

### Problemas confirmados
1. **Despesas enviadas agregadas por categoria, sem nomes individuais** — o prompt envia "Educação: 996.00€" mas nunca "Mestrado ISCTE: 500€ + Curso Udemy: 296€ + Propinas: 200€". O modelo é forçado a inventar.
2. **Compras (PurchaseRecord) têm `items` mas não são enviadas no prompt** — cada compra tem lista de items e valores, mas o prompt só mostra totais agregados.
3. **System prompt diz "usa números concretos" mas não fornece detalhe suficiente** — o modelo cumpre parcialmente mas recorre a hipotéticos quando falta granularidade.
4. **Zero diferenciação entre Premium e Family** — o Family paga +75% mas o coach é idêntico.

---

## Plano de Implementação

### Fase 1: Enviar dados reais detalhados no prompt (core fix)

**Ficheiro:** `ai_coach_service.dart` — método `_buildPrompt`

#### 1a. Incluir despesas individuais nomeadas (não só por categoria)
Na secção DESPESAS FIXAS, em vez de apenas agregar por categoria, listar cada `ExpenseItem` individual:

```
DESPESAS FIXAS: 1850.00€ (62.3% do líquido)
  Habitação: 750.00€ (25.2%)
    - Renda casa: 650.00€
    - Condomínio: 100.00€
  Educação: 996.00€ (33.5%)
    - Mestrado ISCTE: 500.00€
    - Propinas filho: 296.00€
    - Curso online: 200.00€
  Telecomunicações: 104.00€ (3.5%)
    - MEO Fibra: 45.00€
    - Tarifário NOS: 29.00€
    - Netflix: 15.99€
    - Spotify: 13.99€
```

**Implementação:** Iterar `settings.expenses` agrupando por categoria, mas mostrando cada item com `e.label` e `e.amount`.

#### 1b. Incluir top compras individuais no prompt
Na secção COMPRAS, adicionar as últimas N compras com detalhe:

```
COMPRAS — Março 2026
  Compras realizadas: 12
  Valor médio/compra: 38.50€
  Últimas 10 compras:
    - 10 Mar: 65.20€ (Continente — 8 items)
    - 08 Mar: 42.10€ (Pingo Doce — 5 items)
    - 05 Mar: 23.80€ (Lidl — 12 items)
    ...
```

**Implementação:** Adicionar as últimas 10 `PurchaseRecord` do mês com `date`, `amount`, `itemCount`, e `items` (se disponíveis).

#### 1c. Reforçar system prompt anti-hipotéticos
Adicionar ao system prompt:
```
REGRA ABSOLUTA: Nunca uses exemplos hipotéticos como "se tens", "imagina que", "por exemplo".
Refere-te SEMPRE a despesas e compras pelos nomes exactos fornecidos no contexto.
Se não tens detalhe suficiente sobre algo, diz explicitamente "não tenho visibilidade sobre X".
```

### Fase 2: Diferenciação por tier no coach

**Ficheiros:** `ai_coach_service.dart`, `coach_screen.dart`

O método `analyze()` precisa de receber o `SubscriptionTier` para ajustar o comportamento.

#### Tier Premium (€3.99/mês) — Análise Estrutural
- **Modelo:** `gpt-4o-mini` (actual)
- **Max tokens:** 1000 (actual)
- **Prompt:** Envia despesas **agrupadas por categoria** (sem detalhe individual)
- **Compras:** Apenas totais e médias (actual)
- **Directiva:** As 3 partes actuais (posicionamento, factores críticos, oportunidade)

#### Tier Family (€6.99/mês) — Análise Detalhada
- **Modelo:** `gpt-4o-mini` (manter — o custo de gpt-4o seria proibitivo)
- **Max tokens:** 1500 (aumento de 50%)
- **Prompt:** Envia despesas **individuais nomeadas** + top 10 compras com items
- **Directiva extra:** Adicionar parte 4 ao pedido:
  ```
  **4. MICRO-OPTIMIZAÇÕES**
  Identifica 2-3 despesas específicas pelo nome onde há potencial de redução,
  com valor estimado de poupança mensal para cada uma.
  ```
- **Badge visual:** Indicar "Análise Detalhada" no card de resultado

#### Tier Free (trial) — Análise Básica
- **Modelo:** `gpt-4o-mini`
- **Max tokens:** 600 (reduzido)
- **Prompt:** Apenas totais (sem breakdown por categoria)
- **Directiva:** Apenas parte 1 (posicionamento geral) + CTA para upgrade
- **Limite:** 3 análises durante trial

### Fase 3: Actualização da UI

**Ficheiro:** `coach_screen.dart`

- Passar `SubscriptionTier` para `AiCoachService.analyze()`
- No card de resultado, mostrar badge do tier ("Análise Básica" / "Análise PRO")
- Para Family, mostrar a secção extra de micro-optimizações com destaque visual
- Adicionar CTA de upgrade quando em tier inferior

### Fase 4: Mid-month alert com mesma lógica

**Ficheiro:** `ai_coach_service.dart` — método `analyzeMidMonth`

Aplicar a mesma diferenciação por tier ao alerta de meio do mês:
- Family: incluir compras individuais recentes no prompt do alerta
- Premium: manter actual (totais agregados)

---

## Ficheiros a modificar

| Ficheiro | Alteração |
|----------|-----------|
| `lib/services/ai_coach_service.dart` | `_buildPrompt` com detalhe individual, `analyze` com tier, system prompt reforçado |
| `lib/screens/coach_screen.dart` | Passar tier, UI diferenciada por tier |
| `lib/models/subscription_state.dart` | Nenhuma alteração necessária |

## Estimativa de impacto
- **Custo API:** +20-30% tokens no prompt para Family (despesas individuais + compras), compensado por respostas muito mais relevantes
- **Retenção:** Respostas com nomes reais de despesas criam muito mais engagement
- **Upgrade path:** Free→Premium→Family tem proposta de valor clara e diferenciada no coach
