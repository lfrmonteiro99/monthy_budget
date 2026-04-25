import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// One non-centre destination in [CalmBottomNav]. The centre "+" is
/// rendered separately via [CalmBottomNav.onCenterPressed].
class CalmBottomNavItem {
  const CalmBottomNavItem({
    required this.icon,
    required this.label,
    this.tooltip,
    this.badge,
  });

  /// Outlined Material icon. Rendered at 24px.
  final IconData icon;

  /// Tab label. Rendered below the icon at 11pt.
  final String label;

  /// Accessibility / long-press tooltip. Defaults to [label].
  final String? tooltip;

  /// Optional badge widget (e.g. red dot for unread). Stack-positioned
  /// top-right of the icon.
  final Widget? badge;
}

/// Custom 5-slot bottom navigation with a centre filled "+" FAB.
///
/// Layout:
/// ```
///  [item0]   [item1]   ( + )   [item3]   [item4]
/// ```
/// where `( + )` is a 56px black circle with a white "+" glyph,
/// translated -8px above the bar baseline so it appears to "peek".
///
/// **Why custom and not Material `NavigationBar` / `BottomAppBar`:**
/// - Active state uses an ink underline above the icon (not a tinted pill).
/// - Centre item overlaps the bar without a notch — `BottomAppBar` notch
///   is opinionated; we want a clean overlap.
///
/// **Active states:**
/// - Active (non-centre): icon `ink`, label w600 `ink`, 2px ink underline
///   width 20px above icon.
/// - Inactive: icon `ink50`, label w500 `ink50`, no underline.
/// - Centre: always shows the FAB — `selectedIndex` cannot be 2.
class CalmBottomNav extends StatelessWidget {
  const CalmBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCenterPressed,
    this.centerKey,
    this.centerTooltip = 'Adicionar',
  })  : assert(items.length == 4,
            'CalmBottomNav expects exactly 4 items (the centre is the FAB).'),
        assert(selectedIndex >= 0 && selectedIndex < 5 && selectedIndex != 2,
            'selectedIndex must be 0, 1, 3, or 4.');

  /// Four destination items. Visual order:
  ///   items[0], items[1], (centre FAB), items[2], items[3]
  /// To make the index space match `AppTab.navigationIndex` (0,1,3,4),
  /// the convention is: `items[i]` corresponds to slot `i < 2 ? i : i + 1`.
  final List<CalmBottomNavItem> items;

  /// Currently-selected slot index in nav-space (0,1,3,4). Index 2 is
  /// reserved for the FAB and not selectable.
  final int selectedIndex;

  /// Called when the user taps a non-centre destination.
  final ValueChanged<int> onSelected;

  /// Called when the user taps the centre FAB.
  final VoidCallback onCenterPressed;

  /// Optional key for the centre FAB (e.g. for tour highlighting).
  final Key? centerKey;

  /// Centre FAB tooltip / a11y label. Defaults to `'Adicionar'`.
  final String centerTooltip;

  @override
  Widget build(BuildContext context) {
    // Map nav-slot index (0,1,3,4) → items[i] index (0,1,2,3).
    int itemIdx(int slot) => slot < 2 ? slot : slot - 1;

    return Material(
      color: AppColors.card(context),
      elevation: 0,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1px top hairline.
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(height: 1, color: AppColors.line(context)),
              ),
              // Five-slot row.
              Row(
                children: [
                  Expanded(
                    child: _NavSlot(
                      item: items[itemIdx(0)],
                      isActive: selectedIndex == 0,
                      onTap: () => onSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _NavSlot(
                      item: items[itemIdx(1)],
                      isActive: selectedIndex == 1,
                      onTap: () => onSelected(1),
                    ),
                  ),
                  // Centre slot — the "+" FAB.
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -8),
                        child: _CenterFab(
                          key: centerKey,
                          tooltip: centerTooltip,
                          onPressed: onCenterPressed,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _NavSlot(
                      item: items[itemIdx(3)],
                      isActive: selectedIndex == 3,
                      onTap: () => onSelected(3),
                    ),
                  ),
                  Expanded(
                    child: _NavSlot(
                      item: items[itemIdx(4)],
                      isActive: selectedIndex == 4,
                      onTap: () => onSelected(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final CalmBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isActive ? AppColors.ink(context) : AppColors.ink50(context);
    final iconWidget = item.badge != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon, size: 24, color: iconColor),
              Positioned(top: -2, right: -4, child: item.badge!),
            ],
          )
        : Icon(item.icon, size: 24, color: iconColor);

    return Tooltip(
      message: item.tooltip ?? item.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active underline (above the icon per mockup).
              SizedBox(
                height: 6,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: isActive ? 20 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.ink(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              iconWidget,
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({super.key, required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.inkSurface(context),
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              Icons.add,
              size: 28,
              color: AppColors.inkInverse(context),
            ),
          ),
        ),
      ),
    );
  }
}
