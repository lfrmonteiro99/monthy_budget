import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Dark "Coach" hero card used on the More tab (#5 · Insights & mais).
///
/// Reproduces the JSX `CalmMore` coach card: ink-filled surface, subtle
/// radial glow in the top-right corner, sparkle eyebrow, Fraunces quote,
/// pill CTA in the inverse colour. Tapping anywhere on the card runs
/// [onTap] (typically pushing the coach screen).
///
/// The radial glow is the single sanctioned exception to the Calm
/// "no glows" guardrail — see `docs/calm-screen-rollout.md` §5 Não fazer.
class CalmCoachHeroCard extends StatelessWidget {
  const CalmCoachHeroCard({
    super.key,
    required this.eyebrow,
    required this.quote,
    required this.ctaLabel,
    required this.onTap,
    this.semanticsLabel,
    this.trailingPill,
  });

  final String eyebrow;
  final String quote;
  final String ctaLabel;
  final VoidCallback onTap;
  final String? semanticsLabel;

  /// Optional small pill rendered top-right (e.g. "PRO" for free-tier).
  final Widget? trailingPill;

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink(context);
    final inkInverse = AppColors.bg(context);
    final glowColor = inkInverse.withValues(alpha: 0.08);

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: ink,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: IgnorePointer(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [glowColor, Colors.transparent],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: inkInverse.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                eyebrow.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: inkInverse.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trailingPill != null) trailingPill!,
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      quote,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        letterSpacing: -0.2,
                        color: inkInverse,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CtaPill(
                      label: ctaLabel,
                      ink: ink,
                      bg: inkInverse,
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaPill extends StatelessWidget {
  const _CtaPill({
    required this.label,
    required this.ink,
    required this.bg,
    required this.onTap,
  });

  final String label;
  final Color ink;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
