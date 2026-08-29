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
                    _CoachQuoteText(
                      quote: quote,
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

/// Renders [quote] clipped to 3 lines, truncating on a word boundary
/// (never mid-word/mid-number) — Flutter's native `TextOverflow.ellipsis`
/// clips at the glyph level, which can cut a number like "300" down to
/// "30…" when it falls right at the wrap point (issue #1324).
class _CoachQuoteText extends StatefulWidget {
  const _CoachQuoteText({required this.quote, required this.style});

  final String quote;
  final TextStyle style;

  @override
  State<_CoachQuoteText> createState() => _CoachQuoteTextState();
}

class _CoachQuoteTextState extends State<_CoachQuoteText> {
  double? _cachedWidth;
  String? _cachedQuote;
  String? _cachedResult;

  String _resolve(double maxWidth, TextDirection textDirection) {
    if (_cachedResult != null &&
        _cachedWidth == maxWidth &&
        _cachedQuote == widget.quote) {
      return _cachedResult!;
    }
    final result = _truncateWordSafe(
      text: widget.quote,
      style: widget.style,
      maxWidth: maxWidth,
      maxLines: 3,
      textDirection: textDirection,
    );
    _cachedWidth = maxWidth;
    _cachedQuote = widget.quote;
    _cachedResult = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          _resolve(constraints.maxWidth, textDirection),
          maxLines: 3,
          overflow: TextOverflow.clip,
          style: widget.style,
        );
      },
    );
  }
}

/// Returns [text] unchanged if it fits within [maxLines] at [maxWidth];
/// otherwise backs off word-by-word until it fits, then appends '…'.
String _truncateWordSafe({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required int maxLines,
  required TextDirection textDirection,
}) {
  bool exceeds(String candidate) {
    final painter = TextPainter(
      text: TextSpan(text: candidate, style: style),
      maxLines: maxLines,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  if (!exceeds(text)) {
    return text;
  }

  final words = text.split(' ');
  for (var end = words.length - 1; end > 0; end--) {
    final candidate = '${words.sublist(0, end).join(' ')}…';
    if (!exceeds(candidate)) {
      return candidate;
    }
  }
  return '…';
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
