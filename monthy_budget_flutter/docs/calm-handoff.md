# Monthly Budget — Calm Redesign: Handoff

> Pacote de handoff para aplicar o redesign "Calm" no repositório
> [`lfrmonteiro99/monthy_budget`](https://github.com/lfrmonteiro99/monthy_budget),
> sub-app `monthy_budget_flutter/`.
>
> Este documento é auto-contido. Qualquer developer (ou agente) deve conseguir
> executar a migração **sem partir testes**, **sem quebrar CI**, e desenhar
> **ecrãs novos** em conformidade com o sistema — mesmo os que **não estão**
> desenhados no protótipo.

---

## 0. Contexto em 30 segundos

- App: **Orçamento Mensal** (Flutter, Material 3, Supabase, `google_fonts`, `fl_chart`).
- Stack de tema atual: `lib/theme/app_colors.dart` (paletas ocean/emerald/violet/teal/sunset) + `lib/theme/app_theme.dart` (light/dark builders por palette).
- Redesign: **Calm** — paleta warm-neutral (off-white `#F8F7F3`), ink `#0B0E14`, accent indigo `#2F4CDD`, display serif **Fraunces** para números grandes, corpo **Inter**.
- Workflow obrigatório do repo: **branch por issue** (`issue-N-...`), PR com `Fixes #N` + `## Release Notes` + label `release:patch|minor|major`, auto-merge via CI.

---

## 1. Regra de ouro: **não partir testes**

O repo já tem `flutter analyze --no-fatal-infos` + `flutter test` + PR governance em CI. Para que o redesign não quebre nada:

### 1.1 A API pública de `AppColors` **não muda**

Todas as funções antigas (`primary`, `primaryLight`, `onPrimary`, `textPrimary`, `surface`, `background`, `success`, `error`, `warning`, `categoryColor`, `navIndicator`, etc.) continuam a existir — simplesmente são redireccionadas para os tokens Calm. Ver `lib/theme/app_colors.dart` no ZIP anexo.

Resultado: zero call sites precisam de ser editados para o theme novo compilar.

### 1.2 O enum `AppColorPalette` não perde valores

Mantemos `ocean, emerald, violet, teal, sunset` **e** adicionamos `calm`. Código que persiste/lê a palette do utilizador em `SharedPreferences` continua válido. O default passa a `calm`, mas os outros valores ainda resolvem para cores (redireccionadas para Calm na prática; podes manter ou descontinuar noutra issue).

### 1.3 Testes visuais — não assumir goldens

**Este repo não tem golden tests hoje.** Não os estamos a criar de raiz no rollout — o overhead é alto e a estabilidade entre fontes do Google Fonts + plataformas é má.

Em vez disso (ver §5.2): adicionamos na **Issue #5** um *widget-test harness* que valida invariantes do tema (CTA primário usa `ink`, scaffold usa `bg`, chip selected usa `accentSoft`, existem zero `Color(0xFF...)` literais fora de `theme/`). Barato, determinístico, suficiente para apanhar a maior parte das regressões do redesign.

Localmente, confirma só:

```bash
cd monthy_budget_flutter
flutter analyze --no-fatal-infos
flutter test
```

### 1.4 Strings e l10n

**Nenhum** ARB key muda. O redesign é só visual/layout. Se eventualmente alterarmos copy (ex: eyebrow "ESTE MÊS" → "OVERVIEW"), abre-se issue separada com edits em `app_pt.arb` primeiro e só depois os outros locales.

### 1.5 Dependências

Não adicionamos packages. `google_fonts`, `fl_chart`, `flutter_localizations` já estão instalados. A fonte **Fraunces** carrega via `GoogleFonts.fraunces(...)` — o package trata do download e cache.

---

## 2. Design tokens (fonte de verdade)

| Token              | Light              | Dark                          | Usar para                                |
|--------------------|--------------------|-------------------------------|------------------------------------------|
| `bg`               | `#F8F7F3`          | `#12100D`                     | Scaffold background                      |
| `bgSunk`           | `#F1EFE9`          | `#1A1815`                     | Rails, grouped list bg, inputs inativos  |
| `card`             | `#FFFFFF`          | `#1F1D19`                     | Cards, sheets, dialogs                   |
| `ink`              | `#0B0E14`          | `#F5F2EC`                     | Texto primário, CTA fill                 |
| `ink70`            | `#4A5464`          | `#B8B2A5`                     | Texto secundário, labels                 |
| `ink50`            | `#8B93A3`          | `#807A6D`                     | Placeholder, metadata, ícones inativos   |
| `ink20`            | `#DCDED6`          | `#3A3730`                     | Borders fortes, dividers de secção       |
| `line`             | `rgba(11,14,20,.07)` | `rgba(245,242,236,.08)`     | Hairlines, card border                   |
| `accent`           | `#2F4CDD`          | `#8B9BFF`                     | Links, focus ring, selection             |
| `accentSoft`       | `#EAEEFF`          | `accent @ 14%`                | Chip selected, nav indicator, fills subtis |
| `ok`               | `#0E9F6E`          | `#4ADE80`                     | Positive deltas, success pills           |
| `warn`             | `#C2410C`          | `#F59E0B`                     | At-risk budget                           |
| `bad`              | `#B91C1C`          | `#F87171`                     | Over budget, destructive                 |

**Regra crítica**: o CTA primário usa **ink**, não accent. Accent é para selecção e foco, não para botões cheios. Isto é o que distingue Calm de um Material típico.

### Categorias (swatches warmer que os legacy)

Estão em `AppColors.categoryColor(ExpenseCategory)`. Mantém os mesmos `ExpenseCategory` keys — só as cores mudam para combinar com o bg warm.

---

## 3. Tipografia

- **Inter** (existente) → todo o UI body, labels, numbers de linha.
- **Fraunces** (novo) → números grandes de hero (saldo do mês, total da categoria, picos em charts).

Helper `CalmText` em `app_theme.dart`:

```dart
Text('€1 247,30', style: CalmText.display(context, size: 44))      // hero
Text('€42,10',    style: CalmText.amount(context, size: 15))       // list row
Text('ESTE MÊS',  style: CalmText.eyebrow(context))                // section label
```

Regra: **máximo 1 número em Fraunces por ecrã**. Se tiveres dois heroes, um deles é em Inter com tabular figures.

---

## 4. Padrões de layout para ecrãs novos

Isto é o que permite aos developers/agentes desenharem ecrãs **não incluídos** no protótipo (meal planner, paywall, coach, settings, tax simulator, insights, etc.) mantendo coerência.

### 4.1 Grelha

- Padding horizontal do viewport: **20px**.
- Gap vertical entre secções: **32px**.
- Gap entre items dentro da mesma secção: **12px**.
- Radius: cards **20px**, inputs/buttons **14px**, pills **100px** (full).

### 4.2 Anatomia de ecrã (template)

```
┌─────────────────────────────┐
│  ← [título curto]     ⋯     │  ← AppBar transparente, flush com bg
│                             │
│  ESTE MÊS                   │  ← eyebrow (CalmText.eyebrow)
│  €1 247,30                  │  ← hero number (CalmText.display, Fraunces)
│  restam 12 dias             │  ← ink70, 14px
│                             │
│  ────────────────────       │  ← hairline (line)
│                             │
│  Secção                     │  ← ink, 17px semibold
│  ┌─────────────────────┐   │
│  │ card                │   │  ← card com border line, radius 20
│  └─────────────────────┘   │
└─────────────────────────────┘
```

### 4.3 Card pattern

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ESTE MÊS', style: CalmText.eyebrow(context)),
        const SizedBox(height: 8),
        Text('€1 247,30', style: CalmText.display(context)),
        const SizedBox(height: 4),
        Text('restam 12 dias', style: TextStyle(
          fontSize: 14, color: AppColors.ink70(context))),
      ],
    ),
  ),
)
```

### 4.4 Lista de transacções / expenses

- Avatar circular **32px**, preenchido com `categoryColor(cat).withValues(alpha: 0.15)`, ícone a `categoryColor(cat)` 16px.
- Título `ink`, 15px, medium.
- Subtítulo `ink50`, 13px.
- Valor à direita: `CalmText.amount(size: 15, weight: w600)`.
- Divider entre linhas: `Divider(color: AppColors.line(context), height: 1)`.
- Sem cards individuais por linha — lista "bare" num grouped container com radius 20.

### 4.5 Pills de estado

```dart
// Sob budget
_Pill(label: 'ok', color: AppColors.ok(context))
// At risk
_Pill(label: '82%', color: AppColors.warn(context))
// Over
_Pill(label: '+€40', color: AppColors.bad(context))
```

Background da pill = cor com alpha 0.12, texto = cor, 11px w600, radius 100, padding `3px 10px`.

### 4.6 FAB e CTAs

- **CTA primário**: `FilledButton` — fill `ink`, text `bg`, radius 14, altura 52.
- **CTA secundário**: `OutlinedButton` — border `ink20`, text `ink`.
- **FAB**: `ink` fill, ícone `bg`, radius 18. Usar só em dashboard e listas longas (transacções, goals).

### 4.7 Empty states

Centrado, 3 elementos verticais:
1. Ícone **outlined**, 32px, `ink50`.
2. Título 17px semibold `ink`.
3. Frase de contexto 14px `ink70`, max 2 linhas, text-wrap balance.
4. (Opcional) CTA text button `accent`.

Nunca usar ilustrações custom sem aprovação — desenhamos a partir de `Icons.*` outlined do Material.

### 4.8 Bottom sheets e modals

- Radius top 24.
- Drag handle: `AppColors.ink20`, 40×4, centrado, 12px do topo.
- Padding interior 24.
- Título 17px semibold, gap 24 para conteúdo.
- CTA primário full-width no fundo, com safe-area padding.

### 4.9 Charts (`fl_chart`)

- Line/bar: cor principal `AppColors.ink(context)`; highlight da selecção a `AppColors.accent(context)`.
- Grid lines: `AppColors.line(context)`, dashed `[4, 4]`.
- Axis labels: 11px `ink50`.
- Não usar gradients em `BarChart` — fills sólidos.
- Tooltip: bg `ink`, text `bg`, radius 10, sem sombra.

---

## 5. Rollout: issues + branches

Segue o workflow `issue-N-...` + PR com `Fixes #N`. Sugestão de quebra em 6 issues, cada uma pequena e reversível:

Cada PR toca no mínimo de ficheiros possível — nunca agregar ecrãs só por serem "pequenos".

| #  | Issue title                                                               | Ficheiros mexidos                                         |
|----|---------------------------------------------------------------------------|-----------------------------------------------------------|
| 1  | Introduce Calm palette tokens (backward-compatible, `primary`→ink)        | `lib/theme/app_colors.dart`, `app_theme.dart`             |
| 2  | Adopt Calm theme as default + pre-warm Fraunces                           | `lib/main.dart`, splash config                            |
| 3  | **Audit**: remove hard-coded `Color(0x...)` from `lib/` (see §5.1)        | sweep only — no layout changes                            |
| 4  | **Audit**: retire inactive palettes from `AppColorPalette` + Settings UI  | `lib/theme/app_colors.dart`, `settings_screen.dart`, `models/app_settings.dart`, l10n |
| 5  | Add widget-test visual coverage harness (see §5.2) — pre-requisite for 6+ | `test/theme_smoke_test.dart`, `test/helpers/`             |
| 6  | Redesign dashboard hero                                                   | `dashboard_screen.dart`                                   |
| 7  | Redesign dashboard category breakdown                                     | `dashboard_screen.dart`                                   |
| 8  | Redesign expense tracker list + bottom sheet                              | `expense_tracker_screen.dart`                             |
| 9  | Redesign expense trends (charts)                                          | `expense_trends_screen.dart`                              |
| 10 | Redesign recurring expenses                                               | `recurring_expenses_screen.dart`                          |
| 11 | Redesign savings goals                                                    | `savings_goals_screen.dart`                               |
| 12 | Redesign plan hub + plan-and-shop                                         | `plan_hub_screen.dart`, `plan_and_shop_screen.dart`       |
| 13 | Redesign grocery screen                                                   | `grocery_screen.dart`                                     |
| 14 | Redesign shopping list                                                    | `shopping_list_screen.dart`                               |
| 15 | Redesign meal planner + meal wizard                                       | `meal_planner_screen.dart`, `meal_wizard_screen.dart`     |
| 16 | Redesign coach screen                                                     | `coach_screen.dart`                                       |
| 17 | Redesign insights + confidence center                                     | `insights_screen.dart`, `confidence_center_screen.dart`   |
| 18 | Redesign tax simulator + tax deduction detail                             | `tax_simulator_screen.dart`, `tax_deduction_detail_screen.dart` |
| 19 | Redesign notifications screen                                             | `notification_settings_screen.dart`                       |
| 20 | Redesign auth stack (login, gate, biometric, household setup)             | `screens/auth/*`                                          |
| 21 | Redesign onboarding (welcome slideshow, setup wizard)                     | `welcome_slideshow_screen.dart`, `setup_wizard_screen.dart`, `lib/onboarding/` |
| 22 | Redesign paywall + product updates + yearly summary + household activity + more | one PR per screen if non-trivial                    |
| 23 | Redesign settings (LAST — 180KB, split por secção se preciso)             | `settings_screen.dart`                                    |

Cada issue tem uma **checklist de regressão** no PR body:

```
- [ ] `flutter analyze --no-fatal-infos` clean
- [ ] `flutter test` passes
- [ ] Dark mode verified
- [ ] All 4 locales (PT/EN/ES/FR) visually sane
- [ ] No new hard-coded colors (grep: `Color(0x`)
```

### 5.1 Auditoria de cores hard-coded (Issue #3)

Pré-varredura atual: **~183 ocorrências de `Color(0x...)` em `lib/`** fora de `lib/theme/`. A maioria está em screens antigos e em helpers de chart. A migração não está completa enquanto estes existirem — o redesign é visualmente "correcto" mas frágil: qualquer hex drift fica invisível.

**Plano da issue:**

```bash
# Antes de começar, lista:
rg -n "Color\(0x[A-Fa-f0-9]{6,8}\)" lib/ --glob '!lib/theme/**'
```

Para cada hit:
1. Se o valor ≈ um token Calm → substitui por `AppColors.<token>(context)`.
2. Se for semântico (success/warn/bad) → `AppColors.ok/warn/bad(context)`.
3. Se for uma cor de categoria → `AppColors.categoryColor(cat)`.
4. Se for genuinamente único (ex: ilustração) → move a constante para `lib/theme/illustration_palette.dart` e importa daí.

A lint final (sugestão para `analysis_options.yaml`, opcional):

```yaml
# avoid_hardcoded_colors não é oficial; em alternativa, Issue #5 adiciona
# um test que grep-a o tree e falha se hits aparecerem fora de lib/theme/.
```

A Issue #5 materializa este check como teste automatizado — ver abaixo.

### 5.2 Widget-test harness (Issue #5)

Ficheiro: `test/theme_smoke_test.dart`. Objectivo: **invariantes do tema**, não pixels.

```dart
// test/theme_smoke_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';

void main() {
  testWidgets('FilledButton uses ink (not accent) for Calm', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: Scaffold(body: FilledButton(onPressed: () {}, child: const Text('x'))),
    ));
    final ctx = tester.element(find.byType(FilledButton));
    final style = Theme.of(ctx).filledButtonTheme.style!;
    final bg = style.backgroundColor!.resolve({})!;
    expect(bg, AppColors.ink(ctx));
  });

  test('No hard-coded Color(0x...) outside lib/theme/', () {
    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.contains('/theme/')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'Color\(0x[A-Fa-f0-9]{6,8}\)').hasMatch(lines[i])) {
          hits.add('${file.path}:${i+1}  ${lines[i].trim()}');
        }
      }
    }
    expect(hits, isEmpty, reason: 'Use AppColors.* instead:\n${hits.join("\n")}');
  });
}
```

Este test é barato (<200ms), corre no CI existente, e serve de *guard rail* para as issues #6–#23.

### 5.3 Retirar paletas inactivas (Issue #4)

O enum `AppColorPalette { ocean, emerald, violet, teal, sunset, calm }` tem 5 paletas que no novo sistema **resolvem todas para Calm**. Isto é dead code:
- O Settings mostra um picker que não altera nada visível.
- Utilizadores com preferência persistida em `SharedPreferences` (ex: `"emerald"`) vão ler um enum que existe mas não tem efeito.

**Plano:**
1. Colapsa o enum para `AppColorPalette { calm }` (só um valor).
2. Em `AppSettings.fromJson`, mapeia qualquer string não reconhecida → `calm` (migração silenciosa).
3. Remove o picker de paletas do `settings_screen.dart` — ou substitui por toggle light/dark/system apenas.
4. Actualiza ARB keys (se existirem keys tipo `paletteOcean`, removê-las em PT primeiro, depois outros locales).
5. Regenera l10n: `flutter gen-l10n`.

### 5.4 Fraunces — pre-warming (Issue #2)

`google_fonts` faz download on-demand na primeira utilização → **FOUT no primeiro render** do hero número. Mitigação:

```dart
// main.dart, antes de runApp:
GoogleFonts.config.allowRuntimeFetching = true; // default, explicit
await GoogleFonts.pendingFonts([
  GoogleFonts.fraunces(),
  GoogleFonts.inter(),
]);
```

Ou — mais robusto em release — adiciona os ficheiros `.ttf` via `assets:` no `pubspec.yaml` e usa `TextStyle(fontFamily: 'Fraunces')` directamente. Isto elimina a dependência de rede em cold start. Decide na issue #2 conforme o trade-off de tamanho do APK.

---

## 6. Como aplicar agora (passo-a-passo)

```bash
git clone git@github.com:lfrmonteiro99/monthy_budget.git
cd monthy_budget/monthy_budget_flutter

# 1. Cria issue no GitHub: "Introduce Calm palette tokens" → guarda o número, digamos #147.

# 2. Branch a partir de main
git fetch origin main
git checkout -b issue-147-calm-tokens origin/main

# 3. Substitui os dois ficheiros de tema pelos do handoff
#    (ficheiros em handoff/lib/theme/ no ZIP anexo)
cp /path/to/handoff/lib/theme/app_colors.dart lib/theme/app_colors.dart
cp /path/to/handoff/lib/theme/app_theme.dart  lib/theme/app_theme.dart

# 4. Valida
flutter pub get
flutter analyze --no-fatal-infos
flutter test

# 5. Commit + push (nota o #147 na mensagem)
git add lib/theme/
git commit -m "Introduce Calm palette tokens (#147)"
git rebase origin/main
git push -u origin issue-147-calm-tokens

# 6. Abre PR com body:
#    Fixes #147
#    ## Release Notes
#    - Refresh theme with Calm palette tokens. No functional changes.
#    Label: release:minor
```

O CI trata do resto (quality gates + auto-merge).

---

## 7. Checklist de coerência para ecrãs **não desenhados**

Quando fores desenhar um ecrã que não tem mockup (ex: `tax_simulator_screen.dart`, `meal_planner_screen.dart`, `paywall_screen.dart`), usa esta lista:

- [ ] Scaffold background = `AppColors.bg(context)`.
- [ ] AppBar transparente, título 17px semibold, sem ícone de logo.
- [ ] Primeiro bloco do ecrã usa **eyebrow + hero number (Fraunces)** ou **eyebrow + título 17px** — nunca salta directo para conteúdo.
- [ ] Cards com radius 20, border `line`, sem sombra.
- [ ] Padding horizontal 20, vertical gaps múltiplos de 4 (8/12/16/24/32).
- [ ] CTA primário: ink fill.
- [ ] Máximo **uma** cor de categoria por linha da lista.
- [ ] Nenhum gradient.
- [ ] **Nenhuma** cor hard-coded (`Color(0x...)`) — tudo via `AppColors.*(context)`. Corre `rg "Color\(0x" lib/<teu-ficheiro>.dart` antes do commit.
- [ ] Não uses `AppColors.primary(context)` em código novo — é alias de compat. Escolhe explicitamente: `ink` (CTA), `accent` (selecção), `ok/warn/bad` (estado).
- [ ] Testado em dark mode.
- [ ] Testado com string longa em PT/FR (overflow com `TextOverflow.ellipsis`).

Se o ecrã precisar de um padrão que não está listado em §4, **para** e abre uma issue de design antes de codificar.

---

## 8. Anexos no ZIP

- `handoff/lib/theme/app_colors.dart` — novo ficheiro, backward-compatible.
- `handoff/lib/theme/app_theme.dart` — novo ficheiro, inclui `CalmText` helpers.
- `handoff/HANDOFF.md` — este documento.
- `handoff/reference/` — snapshots do protótipo HTML (abrir qualquer um no browser para ver o alvo visual por ecrã).

---

## 9. Contacto / iteração

Se um padrão não cobrir o caso (ex: wizard, calendar picker, mapa com pins), pede um mock específico antes de improvisar. Melhor 1 round de design extra do que fragmentar o sistema.
