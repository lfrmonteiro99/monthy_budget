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
library calm;

export 'calm_scaffold.dart';
export 'calm_eyebrow.dart';
export 'calm_hero.dart';
export 'calm_pill.dart';
export 'calm_card.dart';
export 'calm_empty_state.dart';
export 'calm_bottom_sheet.dart';
export 'calm_list_tile.dart';
