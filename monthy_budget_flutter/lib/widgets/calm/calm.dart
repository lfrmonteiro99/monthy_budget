/// Calm design system — reusable widget library.
///
/// Import this barrel to get all Calm core widgets in one line:
/// ```dart
/// import 'package:monthly_management/widgets/calm/calm.dart';
/// ```
///
/// Widgets in this library:
/// - [CalmScaffold]          — Scaffold wrapper with bg token + SafeArea padding.
/// - [CalmEyebrow]           — Small uppercase section label (11px, w600, ink50).
/// - [CalmHero]              — Eyebrow + Fraunces amount + optional subtitle block.
/// - [CalmPill]              — Status badge with 0.12-alpha tinted background.
/// - [CalmCard]              — Card wrapper with padding 20 + optional InkWell.
/// - [CalmEmptyState]        — Centred empty-state (icon + title + body + optional CTA).
/// - [CalmBottomSheet]       — Static helper wrapping `showModalBottomSheet` with Calm chrome.
/// - [CalmBottomSheetContent]— Default drag handle + title + content layout for sheets.
/// - [CalmListTile]          — Bare transaction row (circular avatar, title, trailing amount).
/// - [CalmHeader]            — 2-line dashboard header with eyebrow + title + trailing actions.
/// - [CalmAvatarBadge]       — Circular initials avatar (36 / 64 px modes).
/// - [CalmPageHeader]        — Back-chevron + eyebrow + Fraunces title for sub-screens.
/// - [CalmTile]              — Vertical icon/label/count quick-action tile.
/// - [CalmMealRow]           — 44px rounded-square thumbnail meal row.
/// - [CalmActionPill]        — Outlined "Gerar"-style pill with optional leading icon.
/// - [CalmWeekGrid]          — 7×N selectable weekly meal grid (+ [CalmWeekGridRow]).
/// - [CalmKpiRow]            — Label/value KPI row with tabular figures.
/// - [CalmCreamPill]         — Warm-cream subscription/premium badge pill.
/// - [CalmSwatchRow]         — 5-circle palette picker (+ [CalmSwatch]).
/// - [CalmBottomNav]         — Custom 4+centre-FAB bottom navigation bar.
library calm;

export 'calm_scaffold.dart';
export 'calm_eyebrow.dart';
export 'calm_hero.dart';
export 'calm_pill.dart';
export 'calm_card.dart';
export 'calm_empty_state.dart';
export 'calm_bottom_sheet.dart';
export 'calm_list_tile.dart';
// Calm redesign additions (mockup waves) ──────────────────────────────────
export 'calm_header.dart';
export 'calm_avatar_badge.dart';
export 'calm_page_header.dart';
export 'calm_tile.dart';
export 'calm_meal_row.dart';
export 'calm_action_pill.dart';
export 'calm_week_grid.dart';
export 'calm_kpi_row.dart';
export 'calm_cream_pill.dart';
export 'calm_swatch_row.dart';
export 'calm_bottom_nav.dart';
