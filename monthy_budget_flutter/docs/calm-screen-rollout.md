<!--
SCREEN_ROLLOUT.md — per-screen instructions for Calm redesign agents.
Companion to HANDOFF.md (foundation: tokens, theme, Fraunces, PR workflow).
-->

# Monthly Budget — Calm Redesign · Per-screen rollout (detailed)

> Documento operacional, ecrã-a-ecrã, para alimentar agentes.
> **Lê primeiro `HANDOFF.md`** (tokens, tipografia, padrões §4, workflow `issue-N-…`).
> Este ficheiro **não repete** princípios — só dá receita por ecrã.

---

## Como usar

Cada ecrã segue **8 blocos fixos**. Não saltar nenhum:

1. **Issue + branch + label** — número da issue de `HANDOFF.md §5`.
2. **Ficheiros tocados** — paths Dart exactos. Path inexistente = abre issue de design **antes** de criar.
3. **Mock de referência** — componente JSX no protótipo + artboard label. Abre `Monthly Budget Redesign.html`.
4. **Dados de entrada** — onde vêm (model, repository, provider, MOCK key equivalente).
5. **Estrutura (top → bottom)** — render order, com tokens, tamanhos, copy literal e tap targets.
6. **Interacções** — taps, long-press, swipe, pull-to-refresh, bottom-sheets, deep-links.
7. **Estados** — empty / loading / error / over-budget / dark / RTL / overflow / sem permissão.
8. **Checklist de regressão** — tudo cumprido antes do `git push` (formato igual a `pull_request_template.md`).

**Regras transversais (não repito por ecrã):**
- Padding horizontal **20px**; gaps verticais 8/12/16/24/32 (múltiplos de 4).
- Radius: cards **20** (no protótipo são 18 — manter 20 no Flutter por consistência com material design tokens), inputs/buttons **14**, pills **100**.
- Eyebrow `CalmText.eyebrow` antes de cada hero number ou título de secção.
- Hero number **Fraunces** via `CalmText.display(context, size: …)`. Máx **1** por ecrã.
- CTA primário usa `ink`. Accent só para foco/selecção/links inline.
- Zero `Color(0x...)` fora de `lib/theme/`.
- Tap target ≥ **44×44**. Lista row mínimo **56px** alta.
- Formatação numérica pt-PT: `€ 647,60` (espaço após €, vírgula decimal). Helper `CalmFormat.money(value)` em `lib/format/calm_format.dart`.
- Animações: 220ms ease-out (push/pop), 180ms (chip toggle), 160ms (switch). Sem bounce.

**Ordem de execução** — fases de `HANDOFF.md §5`. Não saltar:

```
0  foundation       #1–#5     OBRIGATÓRIO
1  pilares          #6 #7 #8           dashboard + expenses
2  suporte          #11 #10 #9         goals, recurring, trends
3  planning         #12 #13 #14 #15    plan-and-shop
4  intelligence     #16 #17            coach, insights
5  fiscal           #18                tax simulator
6  chrome           #19 #20 #21 #22    notifs, auth, onboarding, paywall
7  last             #23                settings
```

---

# FASE 0 — Foundation

`HANDOFF.md §5` cobre #1–#5. Antes de #6, garante:

- [ ] `AppColors` resolve TODOS os tokens da tabela §2 (incluindo `ink70`, `bgSunk`, `accentSoft`).
- [ ] `CalmText.{display,amount,eyebrow}` existe em `app_theme.dart`.
- [ ] `CalmFormat.money/pct/days` existe em `lib/format/calm_format.dart`.
- [ ] `theme_smoke_test.dart` passa.
- [ ] `flutter analyze` clean.
- [ ] `rg "Color\(0x" lib/ --glob '!lib/theme/**'` retorna **zero** linhas.

---

# FASE 1 — Pilares

## #6 · Dashboard hero

| Campo | Valor |
|---|---|
| Branch | `issue-N-dashboard-hero` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/dashboard_screen.dart` (top → 1.º divider, ~linhas 1–180) |
| Mock JSX | `calm.jsx` → `CalmDashboard` (linhas 73–200) |
| Artboard | `01 · Resumo mensal` |
| Dados | `BudgetProvider.currentMonth` → `{income, fixedExpenses, variableSpent, budgetTotal, spent, saved, daysLeft, household, userInitials, month}` |

### Estrutura

**1 · Top header (h=44, padding `14 20 8`)**
- Esquerda: `TextButton` no formato:
  - eyebrow ink50 11px letterspacing 2 uppercase fontweight 600 → `MOCK.household` (ex: "CASA SILVA")
  - linha abaixo: `nav.month` ink 15px + ícone `keyboard_arrow_down` 14px ink50 inline
  - tap → abre `MonthPickerSheet` (radius top 24, lista de 12 meses, marca o actual com tick `accent`)
- Direita: row gap 8
  - `IconButton` 36×36 redondo, border `line`, ícone `notifications_outlined` 18px ink70. **Dot 7×7 `bad`** top-right (offset 7,9) com border 1.5px `bg` se há novas notificações. Tap → push `notifications_screen`.
  - Avatar 36×36 redondo, fill `ink`, text `bg` 12px semibold, conteúdo = `userInitials` (max 2 chars). Tap → push `settings_screen`.

**2 · Hero "Resta" (padding `20 22 18`)**
- Linha 1: `"Resta para este mês"` ink50 13px letterspacing 0.1.
- Linha 2 (hero): `CalmText.display(size: 64)`, lineheight 1.02, fontweight 400.
  - Símbolo `€` em 32px, vertical-align top, fontweight 300, opacity 0.5, margin-right 2.
  - Inteiros: `Math.floor(remaining)` (ex: `647`).
  - Decimais: span 28px opacity 0.45 → `,${(remaining%1).toFixed(2).slice(2)}` (ex: `,60`).
  - Se `remaining < 0`: cor inteira `bad`, prefixo "−" no símbolo.
- Linha 3 (status, gap 10, fontsize 13 ink70 whitespace nowrap):
  - Dot 6×6 — `ok` se `pct ≤ pace` else `warn`.
  - Texto: `"Dentro do ritmo"` ou `"Acima do ritmo"`.
  - Separador `·` ink50.
  - `"${daysLeft} dias restantes"` (singular: `1 dia restante`).
- Linha 4 (margin-top 18): hairline progress
  - Track 2px alto, radius 99, bg `ink20`.
  - Fill `ink` width = `pct%`.
  - **Marca de ritmo**: `Container` 1×8px `ink50` em `left: ${pace}%, top: -3` — onde `pace = dia_actual / dias_no_mês × 100`.
  - Margin-top 8: linha `space-between` 11px ink50: `"€${spent.toFixed(0)} gasto"` ↔ `"de €${budgetTotal.toFixed(0)}"`.

### Interacções

- Pull-to-refresh: `RefreshIndicator` cor `ink`, recarrega o mês actual.
- Long-press no hero: copia `€${remaining}` para clipboard + `SnackBar` (bg ink, text bg, 1800ms).
- Tap no header de mês: abre `MonthPickerSheet`. Trocar de mês recarrega TODO o ecrã.
- Tap na barra de progresso: scroll suave até à secção "Categorias".

### Estados

| Estado | Comportamento |
|---|---|
| Loading | Skeleton: 2 linhas placeholder com shimmer ink20→bgSunk (2s loop). NÃO mostrar valor zero. |
| Empty (mês 1, sem despesas) | `remaining = budgetTotal`, dot `ok`, texto "Mês começa hoje", barra vazia. |
| Over-budget | Hero `bad`, prefixo "−", barra full + segmento extra `bad@40%` à direita até `min(pct, 130%)`. Eyebrow troca para "Excedido este mês". |
| Sem `budgetTotal` | Hero mostra `spent` em `ink`, sublabel "Define um orçamento" + CTA inline accent. |
| Dark | Tokens trocam automaticamente. Verificar que dot `ok` se vê no `#12100D`. |
| Erro de rede | Banner topo `bgSunk`, ícone `cloud_off` ink50 + "Sem ligação. A mostrar dados em cache." |

### Regressão
Ver `pull_request_template.md`.

---

## #7 · Dashboard category breakdown + insight + goals preview

| Campo | Valor |
|---|---|
| Branch | `issue-N-dashboard-categories` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/dashboard_screen.dart` (linhas 180–fim), `lib/widgets/category_row.dart`, `lib/widgets/insight_card.dart` |
| Mock JSX | `calm.jsx` → `CalmDashboard` (linhas 200–360) |
| Artboard | `01 · Resumo mensal` (parte média/inferior) |
| Dados | `CategoryProvider.list(month)`, `InsightProvider.topThree`, `GoalProvider.topTwo` |

### Estrutura

**1 · Categorias (padding `8 20 0`)**
- Header row (margin-bottom 12, baseline align, space-between):
  - Eyebrow `CATEGORIAS` ink50 12px letterspacing 1.5 uppercase semibold.
  - Link "Ver todas" 12px accent semibold → push `categories_overview_screen`.
- Container card radius 18 border `line` overflow hidden:
  - Top 5 categorias por `spent` desc.
  - Cada row 56px alta, padding `14 16`, divider `line` excepto a última.
  - Conteúdo:
    - Linha 1 (justify space-between, align center, margin-bottom 6):
      - Esquerda (gap 10, 14px ink): `CatDot` 7px da `categoryColor(c)` + `c.label`.
      - Direita (14px medium, num font): `€${spent.toFixed(0)} <span ink50> / €${budget}</span>`. Se `over`, valor a `bad`.
    - Linha 2: `Progress` 3px, fill `categoryColor(c)`, track `bgSunk`, value `spent`, max `budget`.
- Tap row → push `category_detail_screen(cat: c)`.

**2 · Insight do mês (padding `22 20 12`)**
- Eyebrow `NOTAS DO MÊS` ink50.
- Card radius 18 border `line` padding 18:
  - Tag (gap 8, 11px ink semibold uppercase letterspacing 0.5): ícone `trending_up` 14px `warn` + `Atenção` (ou `Ótimo`/`Informação` conforme `kind`).
  - Título `CalmText.display(size: 22)` lineheight 1.25, fontweight 400, letterspacing -0.3 — uma frase max 2 linhas. Ex: `"Lazer está 43% acima do planeado este mês."`
  - Body 13px ink70 lineheight 1.5 margin-top 10 — máx 2 frases.
  - Acções (margin-top 14, gap 8):
    - Primária `flex: 1`, padding `10 14`, radius 99, fill `ink`, text `bg`, 13px medium. Ex: "Ajustar orçamento". Tap → push contextual (categoria, meta).
    - Secundária padding `10 14`, radius 99, transparent, border `line`, 13px ink70. Ex: "Ignorar". Tap → marca insight como dismissed (volta da lista por 30 dias).

**3 · Metas preview (padding `12 20 24`)**
- Header igual a Categorias com link "Ver todas" → tab Metas.
- Card radius 18 border `line` padding 18:
  - Top 2 goals. Divider `line` entre eles (margin 16 vertical).
  - Por goal:
    - Linha 1 (baseline, space-between): nome 14px ink medium + ETA 11px ink50.
    - `CalmText.display(size: 28)` margin-top 6: `€${saved}` + `€${target}` 14px ink50 inline.
    - `Progress` 3px, fill `goalColor(g)`, track `bgSunk`, margin-top 8.

### Interacções

- Tap categoria → push detalhe (animação 220ms slide-from-right).
- Tap insight CTA → action contextual (não fecha o card; o card actualiza com confirmação `Toast`).
- Tap "Ignorar" → fade-out 220ms, remove da lista, persiste `dismissed_at` no Supabase.
- Long-press numa categoria → action sheet "Editar orçamento / Ver despesas / Esconder do dashboard".

### Estados

| Estado | Comportamento |
|---|---|
| 0 categorias | Empty state §4.7 — `pie_chart_outline`, "Sem categorias ainda", CTA accent text "Criar primeira" → `category_edit_screen`. |
| Categoria sem orçamento | Pill desaparece, sublabel só `€${spent}`, progress não renderiza. |
| > 8 categorias | Cortar a 5 visíveis + linha "+ N mais" (chevron, ink70 13px) → `categories_overview_screen`. |
| 0 insights | Skip a secção inteira (não mostrar empty state — ruído). |
| Insight com `kind == 'success'` | Tag verde `ok`, ícone `check_circle_outline`. |
| 0 goals | Skip secção. |

---

## #8 · Expense tracker (lista + add sheet)

| Campo | Valor |
|---|---|
| Branch | `issue-N-expenses-list` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/expense_tracker_screen.dart`, `lib/widgets/add_expense_sheet.dart` (criar), `lib/widgets/expense_row.dart` |
| Mock JSX | `calm.jsx` → `CalmExpenses` (linhas 203–278) + `CalmAddSheet` (linhas 280–351) |
| Artboards | `02 · Despesas` + `03 · Nova despesa` |
| Dados | `ExpenseProvider.list({month, query, filters})`, `ExpenseProvider.add(model)` |

### Estrutura — lista

**1 · Header (padding `18 20 8`)**
- Eyebrow `MOVIMENTO`.
- Hero título: `CalmText.display(size: 36)` "Despesas". (Não é um número porque #6 já tem hero monetário; manter regra "1 número Fraunces por ecrã".)
- Stats row (margin-top 14, gap 8). Três cards `flex: 1`, radius 14 border `line` padding `12 14`:
  - Card 1: eyebrow "Este mês" + `CalmText.display(size: 22)` `€${spent.toFixed(0)}`.
  - Card 2: eyebrow "Média/dia" + display `€${spent/dias_decorridos}` arredondado.
  - Card 3: eyebrow "Contas" + display `${expenses.length}` (sem €).

**2 · Search bar (padding `14 20 6`, row gap 8)**
- Pill `flex:1` padding `10 14` bg `card` border `line` radius 99 fontsize 13 ink50:
  - Ícone `search` 16px ink50 + placeholder "Procurar despesa".
- Botão filtro 40×40 redondo bg `card` border `line` ícone `tune` 16px ink70.
  - Tap → `FilterSheet` (categorias multi-select, intervalo de datas, recorrentes only).

**3 · Lista agrupada por dia (padding `10 20 24`)**
- Cada grupo margin-top 14:
  - Header sticky 11px ink50 letterspacing 1.2 uppercase semibold padding `6 4 10`:
    - Esquerda: dia label (`HOJE`, `ONTEM`, `18 ABR`).
    - Direita (num font): `€${total_dia.toFixed(2)}`.
  - Container card radius 16 border `line` overflow hidden:
    - Cada row 56px+ padding `14 16` gap 12, divider `line` excepto última:
      - Avatar 36×36 radius 10, bg `categoryColor(c).withAlpha(0.13)` (~`+'22'` em hex), color `categoryColor(c)`, ícone 18px da `c.icon`.
      - Coluna texto (`flex:1`, minWidth 0):
        - Linha 1 (gap 6 align center): título 14px ink medium + se `recurring`, pill 9px ink50 border `line` padding `1 6` radius 99 texto "recorrente".
        - Linha 2 (margin-top 2): 11.5px ink50 → `${c.label}${note ? " · " + note : ""}` com ellipsis.
      - Valor à direita (15px ink medium, num font tabular): `−€${amount.toFixed(2)}`.

### Estrutura — `add_expense_sheet.dart` (modal bottom sheet)

- Overlay `rgba(11,14,20,0.4)` com `backdropFilter blur 2`. Tap → fecha.
- Container bottom: bg `card`, radius top 28, padding `10 20 22`, max height 88%.
- Drag handle 36×4 radius 99 `ink20` margin `4 auto 14`.
- Top bar (justify space-between, margin-bottom 22):
  - "Cancelar" 14px ink70 → fecha.
  - Título "Nova despesa" 14px semibold.
  - "Guardar" 14px accent semibold → submit (disabled se valor = 0).
- **Hero amount** (text-align center, padding `10 0 22`):
  - `CalmText.display(size: 64)` lineheight 1 letterspacing -0.02:
    - `€` 28px verticalalign top opacity 0.5 margin-right 4.
    - Valor (controlled state).
  - Helper chips abaixo (margin-top 12 gap 6): `EUR`, `+`, `÷` — 34×26 radius 7 border `line` 12px ink70.
- **Loja** (padding `12 14`, border `line`, radius 12, margin-bottom 10, gap 10):
  - Ícone `camera_alt_outlined` 18 ink50.
  - Input flex:1 fontsize 15 ink, autocomplete histórico.
- **Categorias** (margin-top 14):
  - Eyebrow "CATEGORIA".
  - Wrap flex gap 8: chips horizontais de `MOCK.categories.slice(0,8)`. Selected = bg `ink` text `bg` border `ink`. Não-selected = transparent border `line` ink. Cada chip: `CatDot` 8px + label 13px medium.
- **Data + nota** (margin-top 16, row gap 8):
  - Pill flex:1 padding `12 14` border `line` radius 12 14px ink + ícone `calendar_today` 16 ink50 + texto "Hoje, 14:22". Tap → date picker.
  - Botão pequeno "+ Nota" — abre TextField multiline.
- **Sugestão ambiente "talão"** (margin-top 20):
  - Card padding 14 radius 14 bg `accentSoft` row gap 10:
    - Avatar 24×24 radius 99 bg `accent` text `bg` ícone `auto_awesome` (sparkle) 12.
    - Texto 12.5px ink70 lineheight 1.45: "Posso digitalizar o talão para extrair valor, loja e produtos." + link inline accent semibold "Tirar foto ›".
  - Tap → push `receipt_scan_screen`. Resultado preenche o sheet ao voltar.

### Interacções

- Lista: pull-to-refresh, infinite scroll (carregar mais 30 ao chegar a 80% scroll).
- Swipe esquerda numa row → revela "Apagar" `bad` (vermelho) + "Editar" ink70. 80px largura cada.
- Long-press row → action sheet "Duplicar / Editar / Marcar recorrente / Apagar".
- Tap row → push `expense_detail_screen`.
- Sheet: tap fora → confirma se `valor != original` (dialog "Descartar alterações?").
- Sheet: keyboard custom numérico — não usar o do sistema (consistência com mock). Implementar em `lib/widgets/custom_keypad.dart`.

### Estados

| Estado | Comportamento |
|---|---|
| Lista vazia | Empty state — `receipt_long_outlined`, "Sem despesas em ${mês}", CTA "Adicionar primeira" → abre sheet. |
| Search sem resultados | Empty inline (substitui só a lista, mantém stats): `search_off`, "Nada encontrado para '${query}'". |
| Loading inicial | 5 row skeletons shimmer. |
| Sheet — valor 0 | CTA "Guardar" disabled (opacity 0.4). |
| Sheet — valor inválido | Border `bad` no campo, helper text 12px `bad` "Valor inválido". |
| Sheet — submit em progresso | CTA mostra spinner inline 14×14, disabled, texto "A guardar…". |
| Sheet — OCR pendente | Skeleton da lista de items, label "A ler talão…" 14px ink50. |
| Sheet — sem permissão câmera | Card sugestão troca para "Permitir acesso à câmera ›" (mesmo layout, accent text). |

---

# FASE 2 — Suporte

## #11 · Savings goals (lista + detalhe)

| Campo | Valor |
|---|---|
| Branch | `issue-N-savings-goals` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/savings_goals_screen.dart`, `lib/screens/savings_goal_detail_screen.dart`, `lib/widgets/goal_create_sheet.dart` |
| Mock JSX | `calm.jsx` → `CalmGoals` (353–411) + `calm-c.jsx` → `CalmSavingsDetail` |
| Artboards | `04 · Metas` + `19 · Meta · detalhe` |
| Dados | `GoalProvider.list()`, `GoalProvider.detail(id)`, `GoalProvider.deposit(id, amount)` |

### Estrutura — lista

**1 · Header (padding `18 20 8`)**: eyebrow "POUPANÇA" + título display 36px "Metas".

**2 · Card agregado (padding `18 20 4`)**:
- bg `card` radius 18 border `line` padding 18.
- "Total poupado" 12px ink50.
- `CalmText.display(size: 44)` margin-top 4 lineheight 1: `€${sum saved}` formatado pt-PT.
- **Stack bar** margin-top 14:
  - Track 10px radius 99 bg `bgSunk` overflow hidden.
  - Para cada goal: `Container width: ${(saved/totalSaved)*100}%` bg `goalColor(g)`.
- Legend (margin-top 10, wrap, gap 14): por goal — `CatDot` 7px + nome 11px ink70.

**3 · Cards individuais (padding `18 20 24`, gap 12)**:
- bg `card` radius 18 border `line` padding 18.
- Linha 1 (baseline, space-between): nome 15px ink medium + `${pct}%` 11px ink50.
- `CalmText.display(size: 32)` margin-top 8 fontweight 400 lineheight 1.05: `€${saved}` + ` de €${target}` 14px ink50 inline.
- `Progress` 4px margin-top 10.
- Linha rodapé (margin-top 10, space-between, 11.5px ink50): `⌁ €${monthly}/mês` ↔ `Previsto: ${eta}`.

**4 · Botão "Nova meta"**:
- Width 100%, padding 16, radius 18, transparent, border `1.5px dashed ink20`, text ink70 14px medium.
- Ícone `add` 16 + "Nova meta". Tap → `GoalCreateSheet`.

### Estrutura — detalhe (`SavingsGoalDetailScreen`)

**1 · AppBar transparente**: back arrow + "Detalhe" título 17px semibold + ícone `more_horiz` (action sheet "Editar / Pausar / Eliminar").

**2 · Hero (padding 24)**:
- Eyebrow `META` + nome em ink70 13px.
- `CalmText.display(size: 64)` `€${current}` + `de €${target}` 14px ink70.

**3 · Donut chart 160×160 ao centro**:
- `CustomPaint` ou `fl_chart PieChart`.
- Fill `ink` até pct, track `bgSunk`.
- Centro: `${pct}%` 24px ink medium + "completo" 11px ink50.

**4 · Stats row**: 3 colunas separadas por divider vertical 1px line:
- "Mensal" 11px ink50 + `€${monthly}` 17px ink medium.
- "Faltam" 11px ink50 + `${months} meses`.
- "ETA" 11px ink50 + `${eta}`.

**5 · Histórico de depósitos**:
- Eyebrow "DEPÓSITOS".
- Lista bare §4.4 — avatar 32 (ícone `add` em verde `ok` para depósitos, `remove` em `bad` para retiradas) + data + valor.

**6 · CTA fixed-bottom safe-area**:
- "Adicionar depósito" full-width fill `ink` text `bg` radius 14 height 52.
- Tap → `DepositSheet` (numpad + nota opcional).

### Interacções

- Tap card de meta na lista → push detalhe.
- Long-press card → action sheet "Editar / Pausar / Eliminar / Definir como prioridade".
- Donut tap → toggle entre % e valor absoluto.
- Confetti single-shot na primeira vez que `saved >= target` (lib `confetti` ou `simple_animations`). Persistir flag `confetti_shown_${goalId}`.

### Estados

| Estado | Comportamento |
|---|---|
| 0 metas | Empty `flag_outlined`, "Sem metas definidas", body "Define o que poupas todos os meses para um objetivo concreto." CTA "Criar primeira meta". |
| Meta concluída | Pill "Concluída" `ok` no card. No detalhe, hero a `ok` + CTA muda para "Marcar como atingida". |
| Meta pausada | Card opacity 0.6, pill "Pausada" ink50. Sem CTA depósito. |
| Meta atrasada | ETA pill `warn`, hint 13px `warn` "a este ritmo, atrasa 2 meses" no detalhe. |
| Sem deadline | Footer mostra só "⌁ €${monthly}/mês" sem ETA. |
| Loading detalhe | Skeleton: hero number 60% width, donut placeholder cinza, stats row 3 boxes shimmer. |

---

## #10 · Recurring expenses

| Campo | Valor |
|---|---|
| Branch | `issue-N-recurring-expenses` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/recurring_expenses_screen.dart`, `lib/widgets/recurring_edit_sheet.dart` |
| Mock JSX | `calm-a.jsx` → `CalmRecurring` |
| Artboard | `07 · Recorrentes` |
| Dados | `RecurringProvider.list()`, `.toggle(id)`, `.update(id, model)` |

### Estrutura

**1 · `CalmSubHeader`** (helper já no mock, replicar): kicker "DESPESAS" + título "Recorrentes" 28px serif + back arrow esquerda + (opcional) ícone `add` direita.

**2 · Hero stats (padding `18 20 8`)**:
- Eyebrow `${activeCount} ATIVAS · €${monthlySum}/MÊS`.
- Stats row 3 chips outlined:
  - "Próxima" + `dia ${nextDay}`.
  - "Mais cara" + `${topName}`.
  - "Total ano" + `€${monthlySum*12}`.

**3 · Lista agrupada por periodicidade (Mensal / Anual / Semanal)**:
- Header sticky 11px ink50 uppercase letterspacing 1.2.
- Container card radius 16 border `line`:
  - Row 64px alta padding `14 16` gap 12:
    - Avatar 36×36 radius 10 (mesmo padrão que expenses).
    - Coluna texto: título 14px ink medium + sublabel 12px ink50 `dia ${day} · próximo ${next}`.
    - Switch trailing (`active` / `paused`). Switch active = ink fill, thumb bg.
- Indicador "próxima conta < 3 dias": dot 4×4 `warn` à esquerda do avatar.

### Interacções

- Tap row → `RecurringEditSheet` (ext do `add_expense_sheet` com campo extra "Periodicidade" + "Próxima cobrança").
- Toggle switch → optimistic update + `SnackBar` "Pausada · Anular".
- Swipe esquerda → "Apagar".

### Estados

| Estado | Comportamento |
|---|---|
| 0 recorrentes | Empty `repeat`, "Adiciona contas que se repetem", CTA "Adicionar primeira". |
| Pausada | Row opacity 0.5 + pill "Pausada" ink50 inline. |
| Próxima ≤ 3 dias | Dot `warn`. |
| Aniversário (anual a renovar) | Banner topo `accentSoft` "Renda anual renova em 7 dias · €${amount}". |

---

## #9 · Expense trends (yearly)

| Campo | Valor |
|---|---|
| Branch | `issue-N-yearly-trends` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/expense_trends_screen.dart` |
| Mock JSX | `calm-a.jsx` → `CalmYearly` |
| Artboard | `08 · Retrospectiva` |
| Dados | `TrendProvider.year(year)` → `{months[12], spent[12], saved[12], topCats[5], lastYearDelta}` |

### Estrutura

**1 · `CalmSubHeader`** kicker "2026" title "Retrospectiva".

**2 · Hero (padding 24)**: `CalmText.display(size: 56)` soma do ano + sublabel "média €${avg}/mês".

**3 · Chart 12 meses (`fl_chart BarChart`, height 220)**:
- Cores: passados `ink`, mês corrente `accent`, futuros `bgSunk` height média.
- Sem gradients (regra §4.9).
- X labels 11px ink50 (Jan/Fev/...).
- Y axis hidden, gridlines `line` dashed [4,4] cada 25%.
- Tap barra → tooltip bg `ink` text `bg` radius 10 padding `8 12`: "Mar · €1 650".

**4 · Toggle "Gastos / Poupança"** segmented bg `bgSunk` radius 14 height 36 padding 4:
- 2 segmentos `flex:1`. Active = bg `card` text `ink` shadow `0 1 2 rgba(0,0,0,0.04)`.
- Inactive = transparent text ink70.

**5 · Top categorias do ano**:
- Eyebrow "TOP DO ANO".
- Lista bare §4.4 — 5 itens com avatar categoria + nome + valor.

**6 · Card comparação YoY (padding 18 radius 18)**:
- Eyebrow "COMPARADO A 2025".
- `CalmText.display(size: 32)` delta (com sinal). Cor `ok` se negativo, `warn` se positivo.
- Body 13px ink70 "estás €${abs} ${delta<0?'abaixo':'acima'} do mesmo período".

### Estados

| Estado | Comportamento |
|---|---|
| < 3 meses dados | Chart escondido. Mensagem 14px ink70 "Volta em ${date} para veres tendências". |
| Sem ano anterior | Card YoY substituído por "Sem dados de 2025 para comparar". |
| Loading | Bar chart com placeholder bars `bgSunk`. |

---

# FASE 3 — Planning

## #12 · Plan & shop hub

| Campo | Valor |
|---|---|
| Branch | `issue-N-plan-hub` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/plan_hub_screen.dart`, `lib/screens/plan_and_shop_screen.dart` |
| Mock JSX | `calm-b.jsx` → `CalmPlanHub` |
| Artboard | `15 · Plano & compras` |
| Dados | `PlanProvider.weekSummary()` → `{week, weeklyBudget, shoppingItems, plannedDays, pantryAlerts}` |

### Estrutura

- `CalmSubHeader` kicker `SEMANA ${week}` title "Plano & compras".
- Hero `CalmText.display(size: 56)` `€${weeklyBudget}` + sublabel "para esta semana".
- **Grid 2-up** padding `18 20 24` gap 12:
  - Card "Lista de compras" — bg `card` radius 20 border `line` padding 20 height 140:
    - Ícone `shopping_cart_outlined` 24 ink → top-left.
    - Título 16px ink semibold margin-top 12.
    - Sublabel 13px ink50: `${count} itens · €${total}`.
    - Tap → push shopping.
  - Card "Ementa da semana" — `restaurant_outlined`, sublabel `${planned}/7 dias planeados`.
  - Card "Despensa" — `kitchen_outlined`, sublabel `${count} itens${alerts?' · '+alerts+' a esgotar':''}`.
  - Card "Receitas" (opcional, se `RecipeProvider.count > 0`) — `menu_book_outlined`, sublabel `${count} guardadas`.
- Press feedback: bg muda de `card` → `bgSunk` 120ms.

### Estados

| Estado | Comportamento |
|---|---|
| Empty (semana nova) | Cards aparecem todos com state vazio. CTA full-width topo "Planear esta semana" → wizard pré-preenche de despensa + ementas anteriores. |
| Pantry alerts > 0 | Sublabel da despensa em `warn`. |
| Lista incompleta (>50% unchecked, dia próximo do fim) | Card lista com dot `warn`. |

---

## #13 · Grocery (despensa)

| Campo | Valor |
|---|---|
| Branch | `issue-N-grocery-pantry` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/grocery_screen.dart` |
| Mock JSX | `calm-b.jsx` → `CalmPantry` |
| Artboard | `18 · Despensa` |

### Estrutura

- `CalmSubHeader` "Despensa" + ícone `add` direita.
- Eyebrow `${total} ITENS · ${low} EM FALTA`.
- Search bar `bgSunk` radius 14 padding `10 14` ícone `search` ink50.
- Toggle 3 segmentos "Tudo / A esgotar / Validade" (segmented control igual a #9).
- Lista agrupada por aisle (Frescos, Mercearia, Frio, Limpeza, …):
  - Header 11px ink50 uppercase.
  - Row: nome 14px ink + sublabel 12px ink50 `${qty} · validade ${date}` + pill estado direita:
    - `ok` (cheio) verde, `warn` (baixo) laranja, `bad` (esgotado/expirado) vermelho.

### Interacções

- Tap row → bottom-sheet edit (nome, qty, unidade, validade, aisle).
- Long-press → action sheet "Adicionar à lista de compras / Marcar esgotado / Eliminar".
- Swipe esquerda → "Apagar".
- Pull-to-refresh.

### Estados

| Estado | Comportamento |
|---|---|
| Despensa vazia | Empty `kitchen_outlined`, "Despensa vazia", CTA "Importar do último talão" → push `receipt_scan_screen`. |
| Filtro "A esgotar" sem hits | "Tudo em ordem · 0 itens em falta" 14px `ok`. |
| Validade < 3 dias | Pill `warn` no item + dot na header do aisle. |

---

## #14 · Shopping list

| Campo | Valor |
|---|---|
| Branch | `issue-N-shopping-list` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/shopping_list_screen.dart` |
| Mock JSX | `calm-b.jsx` → `CalmShopping` |
| Artboard | `16 · Lista` |

### Estrutura

- `CalmSubHeader` "Lista" + ícone `share_outlined` direita (partilhar com membros do household).
- Eyebrow `${count} ITENS · €${total}`.
- Progress bar checked/total radius 99 height 4 fill `ink` track `bgSunk`. Margin-bottom 18.
- Lista agrupada por aisle:
  - Header sticky.
  - Row 56px:
    - Checkbox 22×22 radius 6, border 1.5 ink20. Checked = bg `ink` + tick branco.
    - Nome 14px ink medium.
    - qty 13px ink50.
    - Preço à direita 14px medium num font.
- Linha checked: opacity 0.4 + strikethrough no nome.
- Sort: unchecked acima de checked (estável dentro de cada bloco).

### Interacções

- Swipe esquerda → "Apagar" `bad`.
- Tap CTA "Concluir compra" (sticky bottom safe-area) full-width fill `ink` — só aparece se `checkedCount > 0`. Tap → confirma "Mover ${n} itens para despesa de hoje?" → cria expense + limpa checked.
- Drag handle no row para reordenar dentro do aisle.
- Tap "+ Adicionar" sticky no fundo de cada aisle.

### Estados

| Estado | Comportamento |
|---|---|
| Lista vazia | Empty `playlist_add_outlined`, CTA "Sugerir da despensa" (preenche com low-stock). |
| Tudo checked | Banner topo `ok` "Tudo apanhado · Concluir compra". |
| Sync entre membros | Indicator "actualizado há ${time}" 11px ink50 footer. |

---

## #15 · Meal planner

| Campo | Valor |
|---|---|
| Branch | `issue-N-meal-planner` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/meal_planner_screen.dart`, `lib/screens/meal_wizard_screen.dart` |
| Mock JSX | `calm-b.jsx` → `CalmMeals` |
| Artboard | `17 · Ementa` |

### Estrutura

- `CalmSubHeader` "Ementa" + chevrons ←/→ semana (centrados no título).
- Eyebrow `SEMANA ${weekRange}`.
- **Grid 7 dias × 3 refeições** (Pequeno-almoço, Almoço, Jantar):
  - Layout: scroll horizontal com 7 colunas 120px wide. Vertical = 3 cells 80px high.
  - Cell vazia: bg `bgSunk` radius 12 + ícone `add` 16 ink50 ao centro. Tap → wizard.
  - Cell preenchida: bg `card` border `line` radius 12 padding 10:
    - Título 12px ink medium 2 linhas max ellipsis.
    - Footer 10px ink50 `${kcal} kcal · €${cost}`.
  - Day header 13px ink semibold + data 11px ink50.

### Wizard (sheet a partir do tap)

- Title "Almoço · Quarta" 17px semibold.
- Search receitas TextField bg `bgSunk` radius 14.
- Sugestões puxadas da despensa (princípio: usar o que tens):
  - Lista vertical, cards 80px alta:
    - Imagem placeholder 56×56 radius 10 (rectangle bg `bgSunk` + label monospace "fotografia: ${nome}" — não SVG inline).
    - Nome 14px ink medium.
    - Sublabel 12px ink50: `${time} min · €${cost} · ${ingredients} ingredientes`.
- CTA "Confirmar" ink fill bottom safe-area.

### Estados

| Estado | Comportamento |
|---|---|
| Semana vazia | Banner topo accentSoft "Planeia em 30s · Sugerir ementa" → AI gera 21 cells. |
| Receita sem preço | Footer mostra só `${kcal} kcal`. |
| Despensa insuficiente | Aviso amarelo "Faltam: arroz, frango" no card de cell. |

---

# FASE 4 — Intelligence

## #5 · Insights & mais (More tab hub)

| Campo | Valor |
|---|---|
| Branch | `issue-N-more-calm-redesign` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/more_screen.dart`, `lib/widgets/calm/calm_coach_hero_card.dart` (novo), `lib/widgets/calm/calm_observation_card.dart` (extraído de #17 para reuso), `lib/app_home.dart` (mantém a tab Mais já mounted), `lib/l10n/app_pt.arb`, `app_en.arb` |
| Mock JSX | `calm-d.jsx` → `CalmMore` |
| Artboard | `05 · Insights & mais` |
| Dados | `BudgetProvider.currentMonth` → `{month, projectedSavings}`; `CoachProvider.headline()` → `{quote, ctaLabel}`; `InsightProvider.topThree()` → até 3 obs `{kind: 'warn'\|'info'\|'ok', title, body}`; `HouseholdProvider.summary()` → `{memberCount, isShared}`; `FeatureFlagProvider` → `taxSimulator`, `receiptOcr` |

### Estrutura

> **Sizes verificadas contra `calm.jsx::CalmMore` (linhas 415–490).** Quando houver discrepância entre esta secção e o JSX, o JSX vence — abrir bug.

**1 · `CalmSubHeader` (padding `18 20 8`)**
- Eyebrow `ENTENDIMENTO` ink50 11px letterspacing 2 uppercase fontweight 600.
- Título `CalmText.display(size: 36)` lineheight 1.1 fontweight 400 → `"Insights & mais"` (l10n: `moreScreenTitle`). Margin-top 6 entre eyebrow e título.
- Sem trailing actions. Sem AppBar Material — a tab Mais usa só o sub-header.

**2 · Coach hero card (wrapper padding `18 20 8`; card padding 20 uniforme; radius 20; fill `ink`; texto `bg`/branco)**
- Glow atmosférico: `Container` 140×140 radial-gradient (`white @ 8% → transparent @ 70%`) absolute top-right offset (-30,-30), `overflow: hidden` no card. **Esta é a única excepção à regra "sem glows" — não generalizar.**
- Eyebrow row (gap 7, margin-bottom — fluxo natural antes do quote): ícone `sparkle` 12px `bg` opacity 0.6 + texto `COACH` 11px `bg` opacity 0.6 letterspacing 1.5 uppercase fontweight 600.
- Quote: `CalmText.display(size: 22)` Fraunces lineheight 1.3 letterspacing -0.2 fontweight 400 cor `bg` (branco em light, ink em dark) — frase do `CoachProvider.headline()`. Margin-top 10. Ex: `"Se mantiveres o ritmo, acabas ${month} com €${projectedSavings} poupados."` Max 3 linhas; após isso, ellipsis.
- CTA pill (margin-top 14): width-content, padding `8 14`, radius 99, fill `bg` (branco), text `ink` 13px fontweight 500 → "Conversar com o coach" (l10n: `moreCoachCta`). Tap → push `coach_screen`.
- Tap em qualquer parte do card (excepto a pill já é tappable) também push `coach_screen` — área tappable inteira.
- Sem subtitle, sem secondary CTA.

**3 · `CalmEyebrow` `OBSERVAÇÕES` (wrapper padding `18 20 0`, marginBottom 12)**
- ink50 11px letterspacing 1.5 uppercase fontweight 600.
- Apenas se `InsightProvider.topThree().isNotEmpty`. Caso contrário, eyebrow + cards skipped (não mostrar empty state — fica em #17).

**4 · Observações (até 3 cards, marginBottom 10 entre cards, padding lateral herdado do wrapper §3)**
- `CalmCard` fill `card` (`#FFFFFF` light / `#1F1D19` dark) radius 16 border 1px `line` padding 16.
- Tag row (gap 6, fontSize 10.5, fontweight 600, letterspacing 0.8 uppercase):
  - Dot 5×5 — `warn` (Atenção) / `accent` (Informação) / `ok` (Ótimo). **Tokens iguais a #17** — não introduzir `bad`.
  - Label correspondente (`Atenção` / `Informação` / `Ótimo`, capitalizado, transformado para uppercase via style) na cor do dot.
- Mapa `kind` na store: `'warning' → warn`, `'success' → ok`, `'info' → accent`. Passar como `enum CalmObservationKind { warning, success, info }`.
- Título 14px ink fontweight 600 letterspacing -0.1 marginTop 7 — uma frase, max 2 linhas. Ex: `"Lazer 43% acima do orçamento"`.
- Body 12.5px ink70 lineheight 1.5 marginTop 4 — máx 2 frases com números/datas concretas. Ex: `"Gastaste €287 este mês vs. €200 planeado. 3 cinemas + 2 restaurantes."`
- O modelo `Insight` tem `action: String` (ver `data.jsx::insights`) — **não renderizar no card** nesta tela; o CTA vive em #17. Tap no card inteiro → push `insights_screen?focus=${obs.id}`.
- Reutilizar `CalmObservationCard` (extraído de #17) — não criar variante.

**5 · `CalmEyebrow` `FERRAMENTAS` (wrapper padding `18 20 24`, marginBottom 12 antes da lista)**
- ink50 11px letterspacing 1.5 uppercase fontweight 600.

**6 · Tools list (1 só card grouped, radius 16 border 1px `line` overflow hidden, fill `card`)**
- 1 só border no container; rows separadas por `Divider(line, height: 1)` excepto a última.
- Cada row é um `<button>` no JSX → em Flutter usar `InkWell` envolto em `Semantics(button: true, label: <título>, hint: <sublabel>)`. Padding `14 16`, gap 14 entre avatar e texto. Altura efectiva ≈ 60dp (avatar 32 + padding 28 = 60); **garantir ≥48dp via `minimumSize`/`MaterialTapTargetSize.padded`** para AA.
  - Avatar 32×32 **rounded-rectangle radius 10** (NÃO redondo) bg `bgSunk` ícone 16px ink70 (neutro — não accent).
  - Coluna texto (flex):
    - Título 14px ink fontweight 500.
    - Sublabel 11.5px ink50 marginTop 1 — uma frase descritiva.
  - Chevron `chevron_right` 16px ink50 à direita (decorativo — `excludeSemantics: true`).
- **Ordem fixa, 13 itens** (verbatim de `calm.jsx:417-431`; itens com feature-flag escondem mantendo a ordem dos restantes):
  1. **Plano & lista de compras** · "Ementa + lista da semana" · ícone `cart` (Material: `restaurant_outlined`) → push `plan_hub_screen`.
  2. **Lista de compras** · "Corredores · progresso" · `cart` (`shopping_cart_outlined`) → push `shopping_list_screen`.
  3. **Ementa da semana** · "7 dias · refeições planeadas" · `calendar` (`calendar_today_outlined`) → push `meal_planner_screen`.
  4. **Despensa** · "Stock em casa · validades" · `home` (`kitchen_outlined`) → push `grocery_screen`.
  5. **Rendimento** · "Salário, freelas, rendas" · `wallet` (`trending_up_outlined`) → push `income_screen`. **(screen + route a criar — não existe hoje no produto)**
  6. **Contas recorrentes** · "Renda, utilities, assinaturas" · `wallet` (`event_repeat_outlined`) → push `recurring_expenses_screen`. **(screen existe; falta `AppRoute.recurring()` — adicionar)**
  7. **Agregado familiar** · "${memberCount} membros · partilhado" (default JSX: "3 membros · partilhado"; se `memberCount == 0`, "Configurar" em `accent` 11.5px) · `users` (`group_outlined`) → push `household_screen`. **(screen + route a criar — só existe spec em #22)**
  8. **Resumo anual** · "Tendências de ${currentYear}" · `trend-up` (`bar_chart_outlined`) → push `yearly_summary_screen`.
  9. **Simulador IRS** · "Deduções e reembolso" · `pie` (`receipt_long_outlined`) → push `tax_simulator_screen`. (oculto se `featureFlag.taxSimulator == false`)
  10. **Digitalizar talão** · "OCR automático" · `camera` (`document_scanner_outlined`) → push `receipt_scan_screen`. (oculto se `featureFlag.receiptOcr == false`)
  11. **Saúde dos dados** · "Categorizações, duplicados" · `sparkle` (`health_and_safety_outlined`) → push `confidence_center_screen` (mesmo destino que #17). Trailing badge 11.5px ink50 com `${alertCount}` se > 0, antes do chevron.
  12. **Notificações** · "Alertas e avisos" · `bell` (`notifications_outlined`) → push `notifications_screen`. (Co-existe com o ícone bell do header do dashboard #6 — ambos válidos.)
  13. **Definições** · "Orçamento, tema, dados" · `target` (`settings_outlined` — desviar do JSX `target` porque em Material `target` não é semanticamente "settings") → push `settings_screen`. (Co-existe com o tap no avatar do dashboard #6.)

- **Itens que NÃO aparecem nesta lista** (ficam noutras superficies — não duplicar):
  - Subscrição → secção dentro de Definições (#23).
  - Centro de Confiança → surface-shared com "Saúde dos dados" (item 11).
  - Atualizações do produto → secção "Sobre" dentro de Definições (#23).
  - Coach (entrada de tile separada) → vive como hero acima; não duplicar.
  - Insights (entrada de tile separada) → acessível via tap nas Observações; não duplicar.
  - Metas de poupança → tab "Metas" no bottom nav; não duplicar.

**7 · `SizedBox(height: 24 + MediaQuery.padding.bottom)` no fim do `ListView`**

### Não fazer (guardrails para esta tela)

- **Não** usar gradientes, glows, sombras coloridas ou emoji em qualquer parte da tela. **Excepção única:** o glow atmosférico radial no Coach hero (descrito em §2) — é parte do desenho e está validado contra o JSX. Não replicar este efeito em mais sítios.
- **Não** introduzir cor fora do que está prescrito: cor só no Coach hero (fill `ink`) e nos dots dos insights (`warn`/`ok`/`accent`). Ferramentas são monocromáticas (avatar `bgSunk`, ícone `ink70`).
- **Não** usar Inter/Roboto como display — só Fraunces para o título da tela e a quote do coach. Inter para tudo o resto.
- **Não** mostrar empty states genéricos ("Ainda não há nada aqui 👋"). Quando `OBSERVAÇÕES` está vazio, **skip da secção inteira**.
- **Não** criar ícones novos — usar exclusivamente o icon set Material já presente no produto (mapeamentos JSX→Material em §6).
- **Não** duplicar entradas que vivem dentro de Definições (Subscrição, Atualizações, Sobre) ou que viraram heroes (Coach, Insights, Metas).

### Interacções

- Pull-to-refresh: `RefreshIndicator` ink, recarrega `CoachProvider.headline()` + `InsightProvider.topThree()`. Tools list é estática.
- Tap no Coach hero (qualquer área): push `coach_screen` (slide-from-right 220ms). Analytics `more.coach_open`.
- Tap numa Observação: push `insights_screen?focus=${obs.id}`. Analytics `more.insight_open` com `kind`.
- Tap numa ferramenta: push da rota correspondente. Analytics `more.tool_open` com `tool: <key>`.
- Long-press numa ferramenta: **nada** (sem action sheet — manter zero estados secundários neste hub).
- Scroll: sub-header não fica sticky; Coach hero scrolla normalmente.

### Estados

| Estado | Comportamento |
|---|---|
| Loading inicial | Coach hero shimmer (ink20→bgSunk, 2s). Observações 2 cards skeleton. Tools list já visível (estática). |
| Coach indisponível (offline / API fail) | Hero mantém-se com frase fallback estática ink70 sobre `ink`: "Toca para abrir o coach." CTA continua activo. Sem skeleton infinito. |
| 0 observações este mês | Eyebrow `OBSERVAÇÕES` + cards inteiramente skipped. NÃO mostrar empty state. |
| 1 ou 2 observações | Renderizar exactamente as que existem; sem placeholders. |
| `featureFlag.taxSimulator == false` | Item "Simulador IRS" não renderiza; ordem dos restantes mantém-se. |
| `featureFlag.receiptOcr == false` | Item "Digitalizar talão" não renderiza. |
| Free tier (`!subscription.hasPremiumAccess`) | Coach hero mostra pill `accentSoft` 11px "PRO" canto superior direito (top 12, right 12). Tap no card → push `paywall_screen` em vez de `coach_screen`. CTA pill troca label para "Desbloquear coach". Tools inalteradas. |
| Dark mode | Coach hero: fill `ink` (em dark = `#F1EFE9`), texto e ícones em `bg` (em dark = `#0B0E14`). Verificar contraste WCAG AA. Tools avatars `bgSunk` continuam OK. |
| Pull-to-refresh offline | Banner topo `bgSunk` 12px ink50 "Sem ligação · Coach indisponível". Observações vêm do cache local. |
| `householdProvider.memberCount == 0` | Item 7 sublabel troca para "Configurar" 12px `accent`. |
| Viewport pequeno (iPhone SE 1.ª gen, 320×568) | Coach hero não pode exceder 38% da viewport vertical — quote trunca a 2 linhas (em vez de 3) com ellipsis. CTA pill mantém-se 100% visível. Tools list scrolla por baixo. |
| Screen reader (TalkBack/VoiceOver) | Coach hero anuncia: "Coach. ${quote}. Botão. Conversar com o coach." Cada tool row anuncia: "${title}. ${sublabel}. Botão." (label + hint, sem ler o chevron). |

### Regressão
Ver `pull_request_template.md`. Específico para esta tela:
- [ ] Densidade ≥13‰ tokens Calm (auditoria `for f in lib/screens/*_screen.dart …`).
- [ ] `MoreScreen` consome `CalmSubHeader` (não AppBar Material) e `CalmCard` para o coach hero (não Container raw).
- [ ] CTA "Conversar com o coach" usa fill `bg` sobre `ink` — **não accent**.
- [ ] Observações usam `CalmObservationCard` partilhado com #17 — diff visual = 0.
- [ ] FERRAMENTAS lista exactamente os 13 itens na ordem prescrita (com feature-flags); zero duplicação de Insights/Coach/Subscrição/Metas.
- [ ] Item "Saúde dos dados" → mesma rota que `confidence_center_screen` de #17.
- [ ] Free tier → pill "PRO" presente no hero e CTA reroteia para paywall.
- [ ] `flutter analyze --no-fatal-infos` clean.
- [ ] `more_screen_test.dart` cobre: 3 secções renderizam, observações vazias skippam secção, feature-flags ocultam tools, free tier mostra pill PRO.

---

## #16 · Coach (chat)

| Campo | Valor |
|---|---|
| Branch | `issue-N-coach` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/coach_screen.dart`, `lib/widgets/chat_bubble.dart` |
| Mock JSX | `calm-d.jsx` → `CalmCoach` |
| Artboard | `12 · Coach (chat)` |
| Dados | `CoachProvider.history()`, `.send(text)`, `.suggestions()` |

### Estrutura

- AppBar: back + título "Coach" 17px semibold + dot `accent` 6×6 ao lado se `unreadInsights > 0` + ícone `more_horiz` (action: "Limpar conversa", "Sobre o coach").
- Lista chat-style com keyboard avoidance:
  - **Bubble AI** (left-align):
    - bg `bgSunk` radius 18 (corner 4 inferior-esquerdo).
    - Padding 14, max-width 78%.
    - Texto 14px ink lineheight 1.45.
    - Avatar 28×28 redondo bg `ink` text `bg` "C" Fraunces 14px — só na **primeira mensagem de cada turn**.
  - **Bubble user** (right-align):
    - bg `ink` text `bg` radius 18 (corner 4 inferior-direito).
    - Avatar 28×28 com `userInitials` ink50 + outline ink20 — também só primeira do turn.
  - Timestamp 11px ink50 entre dias (centro, padding 16).
- Footer (sticky bottom safe-area):
  - **Suggestion chips** (margin-bottom 8, scroll horizontal, gap 8):
    - Pill outlined `ink20` padding `8 14` radius 99 13px ink. Tap → envia como user message.
    - 3 sugestões dinâmicas (do `CoachProvider.suggestions()`).
  - **Input row** (gap 8, padding `8 16 12`):
    - TextField bg `bgSunk` radius 99 padding `12 18` 14px ink hint "Pergunta…".
    - Send button 36×36 redondo ink fill, ícone `arrow_upward` 18 bg. Disabled (opacity 0.4) se input vazio.

### Interacções

- Send: optimistic — bubble user aparece imediatamente, bubble AI mostra **3 dots animados** (180px wide, fade-in stagger 200ms) até resposta.
- Long-press bubble → "Copiar".
- Tap link/CTA dentro de bubble AI → push contextual.
- Pull-down no topo: carrega mais histórico.

### Estados

| Estado | Comportamento |
|---|---|
| Conversa vazia | 1 bubble AI welcome: "Olá ${nome}. Posso analisar o teu mês e sugerir onde poupar." + 3 sugestões. |
| Loading reply | 3 dots animados na bubble AI. NÃO shimmer. |
| Erro | Bubble system center-align `bad` 13px "Não consegui responder. Tenta novamente." + botão "Tentar de novo". |
| Offline | Banner topo `bgSunk` "Sem ligação · Coach indisponível". Input disabled. |
| AI gera CTA accionável | Bubble inclui pill inline accent (ex: "Ajustar orçamento Lazer ›"). |

---

## #17 · Insights + confidence center

| Campo | Valor |
|---|---|
| Branch | `issue-N-insights` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/insights_screen.dart`, `lib/screens/confidence_center_screen.dart` |
| Mock JSX | `calm-d.jsx` → `CalmDataHealth`, secção "Observações" de `CalmMore` |
| Artboards | `05 · Insights & mais` (entry), `14 · Integridade` (data health) |

### Insights screen

- AppBar "Insights" 17px semibold + filtro `tune` à direita (kind multi-select).
- Eyebrow `${count} OBSERVAÇÕES`.
- Lista de cards (gap 12, padding 24 radius 20 border `line`):
  - Tag (gap 6, 11px semibold uppercase letterspacing 0.5): dot 5×5 + label "Atenção" `warn` / "Ótimo" `ok` / "Informação" `accent`.
  - Título Fraunces 22px lineheight 1.3 letterspacing -0.2 — uma frase max 2 linhas.
  - Body 13px ink70 lineheight 1.5 max 3 linhas.
  - Acções (gap 8 margin-top 14): primária pill ink + secundária pill border `line`.

### Confidence center

- `CalmSubHeader` kicker "QUALIDADE" title "Integridade dos dados".
- Hero `CalmText.display(size: 56)` `${score}` (0–100). Sublabel qualitativo: ≥90 "Excelente", 70–89 "Bom", 40–69 "Atenção", <40 "Acção necessária".
- Donut secundário 120×120 mostrando os 4 sub-scores (categorização, duplicados, dados em falta, recência).
- Lista de issues (lista bare):
  - Pill 11px (info/warn/bad) + título 14px ink + body 13px ink70 + CTA accent inline "Resolver ›".
  - Tap CTA → push contextual (ex: tela de duplicados).

### Estados

| Estado | Comportamento |
|---|---|
| 0 insights | Empty `lightbulb_outline`, "Tudo calmo este mês". |
| Insight dismissed | Fade-out 220ms + remove da lista. |
| Score 100 | Hero `ok` + frase celebratória "Dados perfeitos · Mantém assim". |

---

# FASE 5 — Fiscal

## #18 · Tax simulator + deduction detail

| Campo | Valor |
|---|---|
| Branch | `issue-N-tax-simulator` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/tax_simulator_screen.dart`, `lib/screens/tax_deduction_detail_screen.dart` |
| Mock JSX | `calm-c.jsx` → `CalmIRS`, `CalmCategoryEdit` |
| Artboards | `20 · IRS · deduções`, `21 · Categoria · regras` |

### Tax simulator

- `CalmSubHeader` kicker "FISCAL 2026" title "Simulador IRS".
- Hero `CalmText.display(size: 56)` `€${estimatedRefund}` + sublabel "estimativa de reembolso".
- Disclaimer card padding 14 radius 14 bg `bgSunk` 12px ink50 lineheight 1.5: "Estimativa baseada nos dados actuais. Não substitui a declaração oficial."
- Lista categorias dedutíveis (Saúde, Educação, Habitação, IVA dedutível, Pensões):
  - Row 64px padding `14 16` divider `line`:
    - Avatar 36 com ícone categoria.
    - Coluna texto: nome 15px ink medium + sublabel 12px ink50 `€${used} de €${max} · ${pct}%`.
    - Barra horizontal 4px abaixo do sublabel.
    - Chevron direita.
  - Tap → `tax_deduction_detail_screen`.

### Detalhe

- `CalmSubHeader` categoria.
- Hero `CalmText.display(size: 48)` `€${used}` + "de €${max} dedutíveis".
- Progress 8px com marca a `${recommended}%` (max recomendado para o ano).
- Toggle "Aplicar regra automática" (switch + helper "Despesas desta categoria são automaticamente marcadas").
- Lista de despesas elegíveis:
  - Checkbox de inclusão (default checked).
  - Avatar + título + valor + emissor (NIF mostrado em mono 11px ink50).
- Footer disclaimer 12px ink50.

### Estados

| Estado | Comportamento |
|---|---|
| Sem despesas dedutíveis | Empty `receipt_long_outlined`, "Sem deduções este ano". |
| Categoria saturada (used ≥ max) | Pill `ok` "Limite atingido". |
| Despesa sem NIF | Row tag `warn` "NIF em falta" + CTA "Adicionar". |

---

# FASE 6 — Chrome

## #19 · Notifications (lista + prefs)

| Campo | Valor |
|---|---|
| Branch | `issue-N-notifications` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/notifications_screen.dart` (criar), `lib/screens/notification_settings_screen.dart` (existente, redesign) |
| Mock JSX | `calm-notifications.jsx` → `CalmNotifications`, `calm-d.jsx` → `CalmNotificationPrefs` |
| Artboard | `10 · Notificações` |

### Lista

- AppBar "Notificações" + "Marcar tudo lido" 13px accent direita.
- Tabs 2 segmentos "Todas / Não lidas".
- Lista bare:
  - Row 64px padding `14 16` divider `line`:
    - Dot `accent` 6×6 esquerda (só se unread).
    - Avatar 32 ícone categoria.
    - Coluna: título 14px ink (medium se unread) + body 13px ink70 max 2 linhas + timestamp 11px ink50.
  - Tap → push contextual + marca lida.

### Prefs

- Lista grouped:
  - Secção "Orçamento": toggle "Atingiu 80%", "Excedeu", "Resumo semanal".
  - Secção "Metas": toggle "Marco atingido", "Atrasada".
  - Secção "Recorrentes": toggle "3 dias antes", "Cobrança feita".
  - Secção "Coach": toggle "Insights diários", "Sugestões".
- Cada toggle row: título 15px ink + helper 13px ink70 + Switch direita.
- Row "Hora silenciosa" abre time-range picker.

### Estados

| Estado | Comportamento |
|---|---|
| 0 notifs | Empty `notifications_off_outlined`, "Tudo em ordem". |
| 1ª vez sem permissão | Banner topo "Activa notificações para receberes alertas" + CTA accent "Activar". |
| Tab "Não lidas" vazia | "Estás em dia ·". |

---

## #20 · Auth stack

| Campo | Valor |
|---|---|
| Branch | `issue-N-auth` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/auth/login_screen.dart`, `auth_gate_screen.dart`, `biometric_screen.dart`, `household_setup_screen.dart` |
| Sem mock dedicado | Seguir checklist §7 do HANDOFF.md |

### Padrão comum

- bg `bg`, sem AppBar, padding 48 top safe-area.
- Top: logo monogram 40×40 ink (Fraunces "M" se não houver mark).
- Eyebrow + título Fraunces 36px (1 frase descritiva: "Olá de novo" / "Configura a tua casa").
- Form: TextField full-width radius 14 height 56:
  - Label flutuante 11px ink50 → 13px ink ao focar.
  - Border 1px `line`, focus border 1.5px `accent`.
  - Helper text 12px ink50 / `bad` se erro.
- Padding entre fields 12.
- CTA primário ink fill height 52 radius 14 width 100% bottom (com keyboard inset awareness).
- Link secundário 14px accent centrado abaixo do CTA.

### Login

- "Email" + "Palavra-passe" (com toggle olho).
- "Esqueci-me" 13px accent right-align acima do CTA.
- CTA "Entrar".
- Divider `line` com label "ou" no centro.
- Botões SSO outlined (Apple / Google) — só ícone + label, sem branding aggressivo.

### Biometric

- Centro: ícone `fingerprint` ou `face` 64×64 ink.
- "Toca para entrar" 17px ink medium.
- Fallback link "Usar palavra-passe" 14px accent.

### Household setup

- Wizard 3 passos:
  1. Nome do agregado + opcional foto.
  2. Convidar membros (chips com email + role).
  3. Definir orçamento partilhado (slider).

### Estados

| Estado | Comportamento |
|---|---|
| Loading login | CTA mostra spinner inline, disabled. |
| Erro credenciais | Helper text `bad` no field email "Email ou palavra-passe inválidos". |
| Sem internet | Banner topo `bad` "Sem ligação". |
| Biometric falha 3× | Force fallback para password. |

---

## #21 · Onboarding

| Campo | Valor |
|---|---|
| Branch | `issue-N-onboarding` |
| Label | `release:patch` |
| Ficheiros | `lib/screens/welcome_slideshow_screen.dart`, `setup_wizard_screen.dart`, `lib/onboarding/*` |
| Mock JSX | `calm-d.jsx` → `CalmOnboarding` |
| Artboard | `13 · Onboarding` |

### Slideshow (3 slides)

- Layout PageView:
  - Top 60%: placeholder ilustração — `Container` radius 24 bg `bgSunk`, monospace label centro "ilustração: ${nome}". **Não desenhar SVG inline** — passa para design dedicado depois.
  - Bottom 40% padding 24:
    - Eyebrow "BEM-VINDO" / "FUNCIONALIDADES" / "PRIVACIDADE".
    - Título Fraunces 32px lineheight 1.2 max 2 linhas.
    - Body 15px ink70 max 3 linhas text-wrap balance.
- Bottom bar fixed:
  - Indicador 3 dots 6×6 (active = ink 24px wide pill, inactive = ink20 6×6).
  - CTA "Continuar" / "Começar" no último slide. Full-width ink fill.
- "Saltar" 13px ink50 top-right safe-area.

### Wizard (4 passos: identidade, mensal, categorias, ligar contas)

- Progress bar 4px topo (% pasados / total).
- Botão "Anterior" outlined ink20 + CTA "Continuar" ink fill — row gap 8 bottom.
- Cada passo é um Form com inputs §20.

### Estados

| Estado | Comportamento |
|---|---|
| Wizard interrompido | Persistir estado em `SharedPreferences`, retomar do último passo. |
| Skip slideshow | Liga a `setup_wizard` directamente. |

---

## #22 · Paywall + household + product updates + yearly summary

**1 PR por ecrã se não trivial.** Não agregues.

### Paywall (`paywall_screen.dart`, fonte `CalmPaywall`, artboard `22`)

- AppBar transparente só com `close` 24 ink right.
- Eyebrow `MONTHLY PLUS` letterspacing 2.
- Título Fraunces 36px max 2 linhas: "Tudo o que precisas para um ano de paz financeira".
- Lista 4–5 features (gap 18):
  - Row gap 14: ícone 22 ink + coluna (título 15px medium + body 13px ink70 lineheight 1.5).
- Toggle anual/mensal segmented `bgSunk` radius 14 + pill "−20%" inline no anual.
- Card preço bg `card` radius 20 padding 24:
  - Preço Fraunces 40px + "/mês" 14px ink70.
  - Trial info 12px ink50 "7 dias grátis · cancela quando quiseres".
- CTA "Começar 7 dias grátis" full-width ink fill height 52.
- Link "Restaurar compra" 13px accent centrado.
- Footer 11px ink50 lineheight 1.5: ToS + Privacy linked accent.

### Household (`household_screen.dart`, fonte `CalmHousehold`, artboard `11`)

- `CalmSubHeader` nome do household + ícone `settings_outlined`.
- Hero `CalmText.display(size: 56)` `€${monthContrib}` + sublabel "contribuído este mês".
- Lista membros (lista bare):
  - Avatar 40 com iniciais ink em `accentSoft`.
  - Nome 15px ink medium + role 11px uppercase ink50.
  - Direita: `€${memberContrib}` + pill `ok` "em-dia" / `warn` "em-falta".
- Secção "Despesas partilhadas" — lista bare expense rows + chip 11px direita com membro responsável.
- CTA "Convidar membro" outlined ink20 full-width.

### Product updates (`product_updates_screen.dart`, sem mock)

- Lista de updates (timeline):
  - Eyebrow data 11px ink50.
  - Título 15px ink semibold.
  - Body 13px ink70 max 4 linhas.
  - "Saber mais" accent inline → link externo.
- Use insight card pattern (§17).

### Yearly summary (`yearly_summary_screen.dart`)

- Mesmo padrão de #9 (trends) mas com 5–6 secções "story": "Mês mais caro", "Categoria que cresceu mais", "Meta atingida", etc. Cada uma é um card 100vh-ish para storytelling vertical, snap scroll.

---

# FASE 7 — Settings (último)

## #23 · Settings

| Campo | Valor |
|---|---|
| Branch | `issue-N-settings` |
| Label | `release:minor` |
| Ficheiros | `lib/screens/settings_screen.dart` (180KB → split), `lib/widgets/settings/*` |
| Mock JSX | `calm-d.jsx` → `CalmSettings` |
| Artboard | `09 · Definições` |

### Split obrigatório

```
lib/widgets/settings/
  account_section.dart
  appearance_section.dart
  money_section.dart
  categories_section.dart
  household_section.dart
  notifications_section.dart
  privacy_section.dart
  about_section.dart
  setting_row.dart            ← row reusable
  setting_section_header.dart ← header reusable
```

### Estrutura

- `CalmSubHeader` kicker "CONTA" title "Definições".
- Lista grouped (cada secção é um card radius 18 border `line` overflow hidden, gap 18):

**1 · Conta:**
- Row hero: avatar 56 + nome 17px ink semibold + email 13px ink50 + chevron → edit profile.

**2 · Aparência:**
- Tema: list-tile com radio 3 opções (Claro/Escuro/Sistema).
- Idioma: list-tile + valor actual + chevron → picker.
- **Sem picker de paletas** (removido em Issue #4).

**3 · Dinheiro:**
- Moeda (default EUR).
- Início do mês (dia 1–28, se 29+ avisa "alguns meses não têm este dia").
- Símbolo decimal.
- Arredondamento (2 / 0 casas).

**4 · Categorias:**
- "Gerir categorias" → list + reorder + cores.

**5 · Casa partilhada:**
- Atalho para `household_screen` (#22).

**6 · Notificações:**
- Atalho para `notification_settings_screen` (#19).

**7 · Privacidade & dados:**
- Exportar (CSV/JSON) — abre share sheet.
- Apagar conta — text destructive `bad`. Tap → confirm dialog "Esta acção é irreversível" + 2 confirmações.

**8 · Sobre:**
- Versão (read-only "1.4.2 (build 312)") tap 7× ativa debug menu.
- Termos / Privacidade / Open source / Contactar.

### Padrão de row (reusable)

```
SettingRow(
  icon: Icons.palette_outlined,        // 20px ink50
  title: 'Tema',                       // 15px ink
  trailing: 'Sistema',                 // 13px ink50
  onTap: () => …,
)
```

- Height 52px, padding `14 16`, divider `line` excepto última row da secção.
- Header: 11px uppercase ink50 letterspacing 1.5 padding `24 20 8`.

### Migração crítica

- Procurar `AppColors.primary(context)` neste ficheiro:
  - Se for **link/CTA não-destructivo** → manter (alias correcto).
  - Se for **destructive (apagar conta)** → trocar para `AppColors.bad(context)`.
  - Em dúvida → `ink` + comentar no PR.
- Remover toggle de paletas (já feito em #4) — se ainda estiver aqui, é regressão.
- Verificar todas as ARB keys ainda existem (`settingsThemeLight`, etc.) — se removeste algumas, regenera l10n.

### Estados

| Estado | Comportamento |
|---|---|
| Sem foto avatar | Iniciais ink em `accentSoft`. |
| Versão dev | Mostrar "(dev)" sufixo. |
| Apagar conta loading | Dialog mostra spinner, disabled buttons. |

---

# Apêndice A — Como ler o JSX como agente

Cada componente Calm* segue:

```jsx
const CalmXxx = ({ onBack }) => (
  <div style={{ height: '100%', background: TOKEN.bg, ... }}>
    <CalmSubHeader kicker="…" title="…" onBack={onBack}/>
    {/* secções por ordem visual */}
  </div>
);
```

- `kicker=` → eyebrow.
- `title=` → AppBar / hero título.
- Tokens `CA`, `CA_D`, `CB`, `CC` no topo dos ficheiros JSX = `AppColors.*` no Flutter. **Nunca** copies hex literais.
- Helpers JSX comuns: `Icon` (Material-equivalent), `CatDot` (8×8 redondo cor), `Progress` (barra 3px), `Pill` (chip 11px).

# Apêndice B — Quando NÃO seguir este documento

- O ecrã do repo evoluiu (campos novos, features novas que o mock não cobre): **lê o Dart actual primeiro**, abre issue de design adicional.
- Conteúdo real (l10n, dados de produção) não cabe na hierarquia: mantém estrutura, ajusta tamanhos. **Nunca reduzas hero abaixo de 40px; nunca elimines o eyebrow.**
- Plataforma diverge (iOS HIG vs Material): default = Material 3 com tokens Calm. Variantes Cupertino → issue dedicada.

# Apêndice C — Comandos úteis

```bash
# Pre-commit checks
cd monthy_budget_flutter
flutter analyze --no-fatal-infos
flutter test
rg "Color\(0x" lib/ --glob '!lib/theme/**'   # deve dar 0 hits

# Verificar size do ecrã antes de PR
wc -l lib/screens/<screen>.dart    # ideally < 600 lines, split se mais

# Re-gerar l10n após editar ARB
flutter gen-l10n
```

---

*Fim. Para foundation (tokens/theme), volta a `HANDOFF.md`. Para template de PR, vê `pull_request_template.md`.*
