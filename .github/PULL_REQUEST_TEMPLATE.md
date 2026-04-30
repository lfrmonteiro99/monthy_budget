<!--
  Copia este ficheiro para `.github/pull_request_template.md` no repo
  monthy_budget. O GitHub usa-o automaticamente como body de qualquer PR novo.
-->

## Resumo

<!-- 1–3 linhas: que ecrã, que mudou. Não copia da issue. -->

Fixes #<NUM>

## Release Notes

<!-- Vai parar ao changelog. Linguagem de utilizador, não técnica. -->

-

<!-- Label obrigatório no PR: release:patch | release:minor | release:major -->

---

## Calm rollout — checklist (obrigatório antes do merge)

> Esta checklist é o **gate** do redesign. Cada caixa não marcada = razão para o reviewer pedir mudanças.
> A maioria dos checks são automáticos via CI; os visuais têm de ser feitos à mão.

### Foundation (todas as PRs)

- [ ] `flutter analyze --no-fatal-infos` clean
- [ ] `flutter test` passa (incluindo `theme_smoke_test.dart`)
- [ ] `rg "Color\(0x" lib/ --glob '!lib/theme/**'` retorna **zero** linhas no diff
- [ ] Nenhum import directo de `package:google_fonts` fora de `lib/theme/`
- [ ] Nenhuma string hard-coded de UI nova fora de `app_pt.arb` (excepção: debug-only)
- [ ] Sem novos packages no `pubspec.yaml` (se adicionado, justifica em comment)

### Regressão funcional (verificar à mão antes de qualquer check visual)

> **Gate crítico para passes Calm e refactors estruturais.** A density audit só verifica tokens — não apanha botões que viram decorações nem destinos que deixam de ter call-site na UI. Cada caixa não marcada = motivo para bloquear merge.

- [ ] **Todos os botões/widgets interactivos antes do PR continuam interactivos** — nenhum `onTap`/`onPressed`/`onChanged` desapareceu silenciosamente; nenhum `InkWell`/`GestureDetector` foi substituído por `Container`/`Card` sem handler
- [ ] **Sem `onTap: null` novos** — se um row/card é renderizado, ou faz alguma coisa, ou é removido (não fica como placeholder)
- [ ] **Sem rotas órfãs** — qualquer `AppRoute.*` ou `Navigator.push` referenciado tem pelo menos um call-site de UI alcançável (botão, tile, card). Verifica com `rg "AppRoute\.<nome>" lib/`
- [ ] **Sem ecrãs órfãos** — qualquer `Screen` novo ou tocado é instanciado a partir de pelo menos um caminho de UI (não só deep-link). Verifica com `rg "<NomeScreen>\(" lib/`
- [ ] **Toggle/checkbox/swipe testados manualmente** — se o ecrã tem selecção (lista de compras, planner, dashboard cards), confirma que cada interacção produz o efeito esperado e o estado persiste
- [ ] **Estados vazio/loading/erro mostram CTA funcional** — empty state com botão "Adicionar X" ou "Gerar plano" tem o handler ligado, não só o ícone
- [ ] **Deep-link → UI parity** — qualquer destino acessível por deep-link (`orcamentomensal://...`) também é acessível por toque na UI
- [ ] **Back button / Navigator.pop volta a um estado válido** — sem ecrãs presos ou loops
- [ ] **Inputs persistem** — campos editáveis (settings, planner, formulários) guardam o valor após pop/repush do ecrã

### Design tokens

- [ ] Background do scaffold = `AppColors.bg(context)`
- [ ] Cards usam `AppColors.card(context)` + border `AppColors.line(context)` + radius **20** (cards) / **14** (inputs/buttons) / **100** (pills)
- [ ] CTA primário usa `AppColors.ink(context)` (NÃO `accent`, NÃO `primary`)
- [ ] `accent` só aparece em: focus ring, link inline, chip selected, dot/badge de "novo"
- [ ] **Máximo 1** hero number Fraunces no ecrã (`CalmText.display`)
- [ ] Cada secção começa com eyebrow (`CalmText.eyebrow`) — não saltar directo para conteúdo
- [ ] Padding horizontal do viewport = **20px**
- [ ] Tap targets ≥ **44×44**; lista row ≥ **56px** alta

### Tipografia

- [ ] Hero numbers usam `CalmText.display(context, size: …)` (Fraunces)
- [ ] Valores em listas usam `CalmText.amount(context, size: …)` (Inter, tabular figures)
- [ ] Eyebrows usam `CalmText.eyebrow(context)` (11–12px ink50 uppercase letterspacing)
- [ ] Body 13–15px, lineheight 1.45–1.5
- [ ] Sem `GoogleFonts.fraunces(...)` directo no ecrã (passa via `CalmText.*`)

### Estados (verificar à mão)

- [ ] **Empty state** — segue §4.7 (ícone outlined ink50, título 17 semibold, body ink70 max 2 linhas, CTA accent text)
- [ ] **Loading** — skeleton shimmer ink20→bgSunk, sem CircularProgressIndicator solto a meio do ecrã
- [ ] **Error** — banner topo `bad` ou inline + retry button outlined
- [ ] **Dark mode** — testado, contrast ratio AA+ no hero number
- [ ] **PT/EN/ES/FR** — string mais longa não estoura layout (testar com FR ou DE)
- [ ] **Overflow** — `TextOverflow.ellipsis` em todos os títulos de row
- [ ] **Sem internet** — banner ou estado offline tratado

### Animações

- [ ] Push/pop screens 220ms ease-out (sem bounce)
- [ ] Chip toggle 180ms
- [ ] Switch 160ms
- [ ] Sem auto-play de animações no primeiro render que distraiam

### Acessibilidade

- [ ] `Semantics(label: …)` em ícones-only buttons
- [ ] `excludeFromSemantics: true` em decorações (dots, dividers)
- [ ] Texto base scaling: testado a 1.3× (settings → font size grande)
- [ ] Contraste AA: hero ink em bg ≥ 7:1; ink70 em bg ≥ 4.5:1

### Específico do ecrã (preenche por PR)

<!--
  Copia da secção do ecrã em `handoff/SCREEN_ROLLOUT.md` os checks específicos.
  Exemplo para #6 Dashboard hero:
-->

- [ ]
- [ ]
- [ ]

### Migração (se relevante)

- [ ] Removi `Color(0x...)` literais → `AppColors.*`
- [ ] Removi `AppColors.primary(context)` em código novo (só permitido em call-sites legacy não-tocados)
- [ ] Removi referências a paletas `ocean/emerald/violet/teal/sunset` (já mortas após Issue #4)
- [ ] Se mexi em ARB, regenerei l10n (`flutter gen-l10n`) e os 4 locales têm o mesmo set de keys

### Visual review (anexa screenshots)

> Drag-and-drop screenshots aqui. Mínimo: light + dark, mais 1 estado não-default (empty/loading/over-budget/etc.).

| Estado | Light | Dark |
|---|---|---|
| Default | <!-- screenshot --> | <!-- screenshot --> |
| Empty | | |
| Outro: ____ | | |

### Reviewer notes

<!-- Algo que queres que o reviewer olhe especialmente. -->

-

---

<!--
Auto-merge: se todos os checks de CI passarem e tiveres pelo menos 1 approval,
o bot faz merge automático. Não cliques merge manualmente excepto se a label
`do-not-auto-merge` estiver presente.
-->
