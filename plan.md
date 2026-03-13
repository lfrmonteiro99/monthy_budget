# Plano de Implementação: Simplificação UX da App Monthly Budget

## Contexto

A app sofre de **sobrecarga de features com peso visual igual**, resultando numa experiência confusa para utilizadores não-técnicos. A esposa do utilizador resumiu: *"Não sei onde estão as coisas"* e *"Demasiados passos para coisas simples."*

### Princípios orientadores

1. **Features mais usadas = menos taps para chegar**
2. **Coach e Command Chat são produtos distintos** — modelos de negócio, acesso e propósito completamente diferentes. Nunca unificar.
3. **Progressive disclosure** — mostrar o mínimo por defeito, detalhe sob pedido
4. **Não eliminar features** — reorganizar e esconder atrás de hierarquia clara

---

## Fase 1: Eliminar Plan Hub + Reestruturar Navegação (3 tabs)

### Problema
O Plan Hub ocupa 25% da bottom nav mas é apenas um intermediário com 4 cards estáticos. Cada acesso a Grocery, Shopping List ou Meals custa +1 tap desnecessário.

### Implementação

**Ficheiros a alterar:**
- `lib/app_home.dart` — navegação principal, screens array, callbacks
- `lib/screens/plan_hub_screen.dart` — eliminar (ou manter para reutilização futura)
- `lib/screens/plan_and_shop_screen.dart` — **NOVO** ecrã com sub-tabs

**Mudanças concretas:**

1. **Criar `PlanAndShopScreen`** com 3 sub-tabs horizontais (TabBar + TabBarView):
   - **Shopping List** (tab default, o mais usado diariamente)
   - **Grocery** (catálogo de produtos)
   - **Meals** (meal planner)

2. **Alterar bottom navigation** em `app_home.dart` (linhas 1614-1655):
   - Tab 0: **Home** (Dashboard) — mantém
   - Tab 1: **Expenses** (Expense Tracker) — mantém
   - Tab 2: **Plan & Shop** (novo ecrã com sub-tabs) — substitui Plan Hub
   - ~~Tab 3: More~~ — **eliminado**

3. **Badge da Shopping List** migra para o novo Tab 2 (mantém lógica existente das linhas 1629-1647)

4. **Coach sai do Plan Hub** e ganha acesso directo:
   - Ícone dedicado no app bar do Dashboard (psychology icon)
   - Card de discovery no Dashboard para users free (upsell)
   - Mantém ecrã full-screen dedicado (CoachScreen) — faz sentido para sessões longas

5. **Command Chat mantém-se exactamente como está** — FAB flutuante, gratuito, disponível em qualquer ecrã

### Destino das features do "More" tab:

| Feature | Novo local | Acesso |
|---------|-----------|--------|
| Detailed Dashboard | Dashboard → "Ver Relatório Completo" (link no fundo) | 1 tap |
| Insights/Trends | Dentro do relatório completo | 2 taps |
| Savings Goals | Dentro do relatório completo + card no dashboard | 1-2 taps |
| Notifications | Settings → Notificações | 2 taps |
| Subscription | Settings → Subscrição | 2 taps |
| Confidence Center | Settings → Avançado | 2 taps |
| Product Updates | Settings → Sobre | 2 taps |
| Settings | Profile icon no app bar do Dashboard (já existe) | 1 tap |

### Resultado
- 4 tabs → 3 tabs
- Shopping List: 2 taps → 1 tap
- Coach: 2 taps (Plan Hub → card) → 1 tap (ícone no app bar)
- Grocery/Meals: 2 taps → 2 taps (tab + sub-tab, mas sem dead-end intermediário)

---

## Fase 2: Simplificar Dashboard

### Problema
O dashboard renderiza até 18 elementos visuais simultâneos (14 secções internas + 4 wrappers do app_home). Cognitive overload extremo.

### Implementação

**Ficheiros a alterar:**
- `lib/screens/dashboard_screen.dart` (1885 linhas)
- `lib/models/local_dashboard_config.dart`
- `lib/app_home.dart` (wrappers do dashboard)

**Mudanças concretas:**

1. **Dashboard principal mostra apenas 4-5 elementos:**
   - Hero Card (resumo do orçamento — já existe, `showHeroCard`)
   - Quick Add Expense button (proeminente, single tap — ver Fase 4)
   - Upcoming Bills (apenas se algo vence nos próximos 3 dias, compacto)
   - Stress Index (uma linha, compacto)
   - Link "Ver Relatório Completo" no fundo

2. **Alterar `LocalDashboardConfig` defaults** (linhas 4-40):
   - `showHeroCard: true` (mantém)
   - `showStressIndex: true` (mantém, mas renderizar compacto)
   - `showUpcomingBills: true` (mantém)
   - Todos os outros: `false` por defeito
   - **Eliminar toggle `focusedMode`** — o dashboard principal É agora o modo focado

3. **"Ver Relatório Completo"** abre o equivalente ao actual "Detailed Dashboard" (que já usa `LocalDashboardConfig.full()`). Reutilizar a lógica existente de `_openDetailedDashboard()` (linhas 738-795).

4. **Eliminar Dashboard Customization** dos Settings — a dualidade focado/completo substitui os 15+ toggles. Menos decisões = menos confusão.

5. **Wrappers do app_home** (linhas 1554-1600):
   - `TrialBanner` — mover para dentro do Settings ou mostrar como snackbar
   - `FeatureDiscoveryCard` — manter mas apenas 1 de cada vez
   - `CriticalAlertBanner` — manter (é crítico)
   - `AdBannerWidget` — manter

### Resultado
- 18 elementos → 5 elementos no dashboard principal
- Toda a informação detalhada continua acessível via "Ver Relatório Completo"
- Zero configuração necessária pelo utilizador

---

## Fase 3: Simplificar Add Expense

### Problema
O fluxo actual tem 2 tiers de selecção (expense item → category) com 4-6 taps mínimos. Para a acção mais frequente da app, é demasiado.

### Implementação

**Ficheiros a alterar:**
- `lib/widgets/add_expense_sheet.dart`
- `lib/widgets/quick_add_launcher.dart`

**Mudanças concretas:**

1. **Inverter a ordem do formulário** — amount first:
   - Campo de valor auto-focused com numpad aberto (linha 411+)
   - Categoria como dropdown flat (uma lista só, sem tier 1/tier 2)
   - Data default: hoje (tap para alterar, mas não obrigar)
   - Descrição: opcional, colapsada
   - Botão Guardar

2. **Flatten a selecção de categoria:**
   - Eliminar distinção "expense item" vs "category"
   - Uma única lista de chips/dropdown com todas as categorias do budget + custom
   - Quando user selecciona categoria, auto-preenche com a mais recente expense item dessa categoria (se existir)

3. **Simplificar FAB Speed Dial** (quick_add_launcher.dart):
   - **Substituir speed dial (5 acções) por single FAB "Add Expense"** no Dashboard
   - As outras acções já são acessíveis:
     - Shopping List → Tab "Plan & Shop" (Fase 1)
     - Meals → Tab "Plan & Shop" sub-tab (Fase 1)
     - Command Chat → FAB flutuante (já existe)
     - Scan Receipt → ícone no app bar do Expense Tracker

### Resultado
- Add expense: 4-6 taps → 3 taps (valor → categoria → guardar)
- FAB: 5 opções com choice paralysis → 1 acção directa
- Numpad aparece imediatamente ao abrir o sheet

---

## Fase 4: Reduzir Onboarding

### Problema
11 ecrãs antes do user ver a app (6 wizard + 5 slideshow). A maioria dos users desiste antes de terminar.

### Implementação

**Ficheiros a alterar:**
- `lib/screens/setup_wizard_screen.dart`
- `lib/screens/welcome_slideshow_screen.dart` — eliminar
- Tour files em `lib/onboarding/`

**Mudanças concretas:**

1. **Colapsar wizard de 6 para 3 ecrãs:**
   - **Ecrã 1: Bem-vindo + País** — combinar Step 0 (welcome) + Step 1 (country). Welcome message em cima, country picker em baixo, tudo num ecrã.
   - **Ecrã 2: Rendimento + Budget** — combinar Step 2 (personal info) + Step 3 (salary) + Step 4 (expenses). Campos essenciais apenas: salário bruto, lista de despesas com valores editáveis. Marital status e dependentes movem para Settings.
   - **Ecrã 3: Pronto** — Step 5 (completion), ir directamente para o Dashboard.

2. **Eliminar Welcome Slideshow** — zero slides. O slideshow repete informação que o user vai descobrir naturalmente.

3. **Tours contextuais em vez de tours completos:**
   - Manter a infraestrutura de tours
   - Mas trigger **apenas 1 tooltip por sessão** (não o tour completo de 3-5 steps)
   - Prioridade: mostrar o tooltip mais relevante para a acção que o user acabou de tentar
   - Marcar como visto após mostrar

### Resultado
- Onboarding: 11 ecrãs → 3 ecrãs
- Slideshow: 5 slides → 0
- Tours: avalanche de tooltips → 1 tooltip contextual por sessão

---

## Fase 5: Reestruturar Settings

### Problema
10+ accordion sections numa página, sem agrupamento. O user que quer mudar o salário tem de procurar entre 10 secções.

### Implementação

**Ficheiros a alterar:**
- `lib/screens/settings_screen.dart` (refactor pesado)

**Mudanças concretas:**

1. **Substituir accordions por lista agrupada estilo iOS/Android Settings:**

   ```
   CONTA
   ├── Informação Pessoal → ecrã dedicado
   ├── Agregado Familiar → ecrã dedicado
   └── Subscrição → ecrã dedicado

   ORÇAMENTO
   ├── Salários → ecrã dedicado
   ├── Categorias de Despesa → ecrã dedicado
   ├── Orçamentos Mensais → ecrã dedicado
   └── Despesas Recorrentes → ecrã dedicado

   PREFERÊNCIAS
   ├── Aparência (tema, paleta) → ecrã dedicado
   ├── Notificações → ecrã dedicado
   ├── Refeições → ecrã dedicado
   └── Produtos Favoritos → ecrã dedicado

   AVANÇADO
   ├── AI Coach (API Key) → ecrã dedicado
   ├── Centro de Confiança → ecrã dedicado
   └── Sobre / Novidades → ecrã dedicado

   [Terminar sessão]
   ```

2. **Cada item navega para um ecrã dedicado** (não expande inline). Isto é standard mobile UX — iOS Settings, qualquer app bancária.

3. **Features do "More" tab** que migraram para Settings ficam nos grupos acima.

4. **Meals Settings**: A secção de Meals nos settings tem 7 sub-grupos (A-G) com ~30 campos. Manter a complexidade mas distribuída em sub-ecrãs navegáveis, não tudo visível de uma vez.

### Resultado
- 10+ accordions → 4 grupos com ~13 items navegáveis
- Cada item abre ecrã dedicado (não accordion)
- Agrupamento lógico facilita a descoberta

---

## Fase 6: Simplificar Meal Planner (Progressive Disclosure)

### Problema
Complexidade enterprise-grade num consumer app: wizard de 5 steps, multi-week tabs, AI enrichment, pantry matching, nutrition summaries, cost reconciliation.

### Implementação

**Ficheiros a alterar:**
- `lib/screens/meal_planner_screen.dart`
- `lib/screens/meal_wizard_screen.dart`

**Mudanças concretas:**

1. **Vista default simplificada:**
   - Grelha semanal (7 dias × refeições activas)
   - Tap numa célula → atribuir refeição (sugestão ou freeform)
   - Sem nutrition summaries, budget insights, ou pantry chips na vista principal

2. **Detalhes sob pedido:**
   - Nutrição, custo, receita completa → aparecem quando user tapa numa refeição específica
   - Pantry matching → badge subtil no card (ex: "3/5 ingredientes em casa")
   - Budget insight → card no fundo, colapsado por defeito

3. **Navegação temporal:**
   - Substituir tabs W1-W4 por date navigator (setas ← →), igual ao expense tracker
   - Consistência visual entre ecrãs

4. **Wizard → Settings:**
   - Wizard de 5 steps já não aparece no primeiro acesso
   - Em vez disso, valores default sensatos + link "Personalizar preferências" no app bar
   - Preferências de refeições ficam nos Settings (Fase 5) já reestruturados

### Resultado
- Vista principal: ~10 elementos → grelha + 1 botão de acção
- Wizard: 5 steps upfront → 0 (configuração em Settings)
- Detalhes: sempre visíveis → sob pedido

---

## Ordem de Implementação e Dependências

```
Fase 1 (Navegação)     ← PRIMEIRO: altera a estrutura base
  ↓
Fase 2 (Dashboard)     ← depende da nova nav (link "Ver Relatório", Coach icon)
  ↓
Fase 3 (Add Expense)   ← independente mas beneficia do novo FAB single
  ↓
Fase 4 (Onboarding)    ← adaptar ao novo layout (3 tabs, não 4)
  ↓
Fase 5 (Settings)      ← recebe features migradas das fases anteriores
  ↓
Fase 6 (Meal Planner)  ← última, mais complexa, menos impacto imediato
```

## Comparação de Taps (Antes vs Depois)

| Acção | Antes | Depois |
|-------|-------|--------|
| Add expense (Dashboard) | 2 (FAB → Add Expense) | 1 (single FAB) |
| Open Shopping List | 2 (Plan tab → card) | 1 (Plan & Shop tab) |
| Open Coach | 2 (Plan tab → card) | 1 (ícone no app bar) |
| Open Settings | 3 (More → Settings → scroll) | 1 (profile icon) |
| View Insights | 2 (More → Insights) | 2 (Dashboard → Full Report) |
| Completar onboarding | 11 ecrãs | 3 ecrãs |
| Add known expense | 4-6 taps no sheet | 3 taps no sheet |
| Open Grocery | 2 (Plan tab → card) | 2 (Plan & Shop → sub-tab) |
| Open Meals | 2 (Plan tab → card) | 2 (Plan & Shop → sub-tab) |

## Notas Importantes

- **Coach e Command Chat permanecem 100% separados** — produtos distintos com modelos de negócio diferentes
- **Nenhuma feature é eliminada** — apenas reorganizadas com hierarquia clara
- **Backward compatibility**: dados do user (dashboard config, onboarding state, tours) precisam de migração
- **Testes**: cada fase deve incluir testes de widget para a nova navegação
- **Localização**: novas strings l10n necessárias para labels alterados
