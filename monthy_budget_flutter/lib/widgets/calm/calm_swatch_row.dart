import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// One palette option in a [CalmSwatchRow].
class CalmSwatch {
  const CalmSwatch(this.label, this.color);

  /// Short display label rendered below the circle (e.g. `'Calm'`).
  final String label;

  /// Swatch fill colour.
  final Color color;
}

/// Horizontal palette picker: N coloured circles, label below each, with
/// an ink ring around the currently-selected swatch.
///
/// Used in Definições "Paleta de cor" (mockup #4).
///
/// **Geometry:**
/// - Swatch circle: 32px diameter.
/// - Selected ring: 2.5px ink, gap 3px between ring and swatch (rendered
///   via outer 40px container with border).
/// - Label: 11/w500 ink70 below, 6px gap.
/// - Inter-swatch gap: equal flex via `Spacer`s, OR fixed 16px on overflow.
class CalmSwatchRow extends StatelessWidget {
  const CalmSwatchRow({
    super.key,
    required this.swatches,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// List of palette options.
  final List<CalmSwatch> swatches;

  /// Index of the currently-selected swatch in [swatches].
  final int selectedIndex;

  /// Called with the new index when the user taps a swatch.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < swatches.length; i++)
          _SwatchItem(
            swatch: swatches[i],
            isSelected: i == selectedIndex,
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}

class _SwatchItem extends StatelessWidget {
  const _SwatchItem({
    required this.swatch,
    required this.isSelected,
    required this.onTap,
  });

  final CalmSwatch swatch;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.ink(context), width: 2)
                    : null,
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: swatch.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              swatch.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.ink70(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
