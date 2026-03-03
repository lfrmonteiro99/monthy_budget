# Índice de Tranquilidade Financeira — Design

**Goal:** Adicionar um card ao Dashboard com um score 0–100 que resume a saúde financeira do utilizador, persistindo o histórico mensal para mostrar evolução.

**Architecture:** Cálculo em tempo real no Dashboard, score guardado em `AppSettings.stressHistory` (Map<String, int>) usando o `settings_json` existente no Supabase — zero schema changes.

**Tech Stack:** Flutter, Dart, Supabase (existing settings_json field), existing BudgetSummary + PurchaseHistory models.

---

## Fórmula (0–100)

Quatro factores, cada um normalizado para 0–100 e depois ponderado:

| Factor | Peso | Fonte | Normalização |
|--------|------|-------|--------------|
| Taxa de poupança | 35% | `summary.savingsRate` | 0% = 0pts, ≥25% = 100pts (linear) |
| Margem de segurança | 30% | `summary.netLiquidity` | ≤0€ = 0pts, ≥500€ = 100pts (linear clamp) |
| Orçamento alimentar | 20% | `spentInMonth / foodBudget` | ratio ≥1.0 = 0pts, ratio=0 = 100pts |
| Estabilidade despesas | 15% | `1 - (totalExpenses / totalNet)` | ratio ≥1.0 = 0pts, ratio=0 = 100pts |

Score final = soma ponderada, arredondada ao inteiro, clamp 0–100.

**Labels:**
- 80–100 → "Excelente" (verde `#10B981`)
- 60–79 → "Bom" (azul `#3B82F6`)
- 40–59 → "Atenção" (âmbar `#F59E0B`)
- 0–39 → "Crítico" (vermelho `#EF4444`)

**Factor status (✓ / ⚠):**
- Poupança: ✓ se savingsRate ≥ 0.10, else ⚠
- Margem: ✓ se netLiquidity ≥ 100€, else ⚠
- Alimentação: ✓ se ratio ≤ 0.80, else ⚠
- Estabilidade: ✓ se expenseRatio ≤ 0.70, else ⚠

---

## UI — Card no Dashboard

**Posição:** imediatamente abaixo do hero de liquidez, antes dos summary cards.

**Layout (collapsed por defeito):**
```
┌──────────────────────────────────────────┐
│ ● ÍNDICE DE TRANQUILIDADE                │
│                                          │
│   72           Bom  ▲ +3 vs mês passado │
│   ████████████░░░░  (LinearProgress)     │
│                                          │
│  [Tap para ver detalhes ▾]               │
└──────────────────────────────────────────┘
```

**Layout (expanded):**
```
┌──────────────────────────────────────────┐
│ ● ÍNDICE DE TRANQUILIDADE                │
│                                          │
│   72           Bom  ▲ +3 vs mês passado │
│   ████████████░░░░                       │
│                                          │
│  ✓ Taxa de poupança    18%               │
│  ✓ Margem de segurança 487€             │
│  ⚠ Alimentação         82% do orçamento │
│  ✓ Estabilidade        estável           │
│                                          │
│  [Fechar ▴]                              │
└──────────────────────────────────────────┘
```

- Cor da barra e número = cor do label
- "+N vs mês passado" só aparece se `stressHistory` tiver score do mês anterior
- "▲" verde se melhorou, "▼" vermelho se piorou, sem seta se primeiro mês

---

## Dados e Persistência

**AppSettings novo campo:**
```dart
final Map<String, int> stressHistory; // {"2026-02": 72, "2026-01": 69}
// chave formato: "YYYY-MM"
```

**Fluxo de save:**
1. DashboardScreen recebe `onSaveSettings: ValueChanged<AppSettings>`
2. Ao renderizar, calcula score do mês actual
3. Compara com `stressHistory["YYYY-MM"]`:
   - Se não existe ou é diferente → chama `onSaveSettings(settings.copyWith(stressHistory: {..., "YYYY-MM": score}))`
4. Delta = score actual - `stressHistory` do mês anterior (se existir)

**Serialização:**
```dart
// AppSettings.toJsonString()
'stressHistory': stressHistory.map((k, v) => MapEntry(k, v)),

// AppSettings.fromJsonString()
stressHistory: (map['stressHistory'] as Map<String, dynamic>?)
    ?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
```

---

## Ficheiros a Modificar

- `lib/models/app_settings.dart` — adicionar `stressHistory` field
- `lib/utils/stress_index.dart` — NEW: função pura `calculateStressIndex(BudgetSummary, PurchaseHistory, AppSettings) → StressIndexResult`
- `lib/screens/dashboard_screen.dart` — adicionar `onSaveSettings` param + `_StressIndexCard` widget
- `lib/main.dart` — passar `onSaveSettings: _saveSettings` ao DashboardScreen
