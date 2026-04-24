import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_theme.dart';

/// A small uppercase section label styled to the Calm eyebrow spec:
/// 11px Inter, w600, letterSpacing 1.2, colour `ink50`.
///
/// Use above section headings or hero blocks — e.g. `"ESTE MÊS"`.
/// Screens never need to hand-roll the style; this widget is the
/// single source of truth for the eyebrow treatment.
class CalmEyebrow extends StatelessWidget {
  const CalmEyebrow(
    this.label, {
    super.key,
    this.textAlign,
  });

  /// The short, typically uppercase label to display.
  final String label;

  /// Optional text alignment. Defaults to [TextAlign.start].
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: CalmText.eyebrow(context),
      textAlign: textAlign,
    );
  }
}
