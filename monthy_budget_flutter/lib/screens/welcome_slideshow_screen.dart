import 'package:flutter/material.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// WelcomeSlideshowScreen — Calm redesign §21 (Wave M7)
// 3-slide PageView: 60 % illustration placeholder / 40 % copy block.
// ---------------------------------------------------------------------------

class WelcomeSlideshowScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeSlideshowScreen({super.key, required this.onComplete});

  @override
  State<WelcomeSlideshowScreen> createState() => _WelcomeSlideshowScreenState();
}

class _WelcomeSlideshowScreenState extends State<WelcomeSlideshowScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: AppConstants.animPageTransition,
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isLast = _currentPage == 2;

    return CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: Stack(
        children: [
          // ── Main layout ────────────────────────────────────────────────
          Column(
            children: [
              // PageView takes all available space minus the bottom bar
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    // ── Slide 1 ────────────────────────────────────────
                    _buildSlide(
                      context: context,
                      eyebrow: CalmEyebrow(l10n.welcomeSlideWelcomeEyebrow),
                      illustrationName: 'boas-vindas',
                      title: l10n.welcomeSlideWelcomeTitle,
                      body: l10n.welcomeSlideWelcomeBody,
                    ),
                    // ── Slide 2 ────────────────────────────────────────
                    _buildSlide(
                      context: context,
                      eyebrow: CalmEyebrow(l10n.welcomeSlideFeaturesEyebrow),
                      illustrationName: 'funcionalidades',
                      title: l10n.welcomeSlideFeaturesTitle,
                      body: l10n.welcomeSlideFeaturesBody,
                    ),
                    // ── Slide 3 ────────────────────────────────────────
                    _buildSlide(
                      context: context,
                      eyebrow: CalmEyebrow(l10n.welcomeSlidePrivacyEyebrow),
                      illustrationName: 'privacidade',
                      title: l10n.welcomeSlidePrivacyTitle,
                      body: l10n.welcomeSlidePrivacyBody,
                    ),
                  ],
                ),
              ),
              // ── Dot indicator ──────────────────────────────────────────
              _SlideIndicator(count: 3, current: _currentPage),
              const SizedBox(height: 16),
              // ── CTA button ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _advance,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink(context),
                      foregroundColor: AppColors.bg(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isLast ? l10n.welcomeSlideStart : l10n.welcomeSlideContinue,
                      style: CalmText.amount(context, size: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
          // ── "Saltar" — top-right safe-area, slides 1-2 only ───────────
          if (!isLast)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: GestureDetector(
                  onTap: widget.onComplete,
                  child: Text(
                    l10n.welcomeSlideSkip,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.ink50(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a single slide with 60/40 split.
  /// The illustration [Container] is the SOLE Container per §21.
  Widget _buildSlide({
    required BuildContext context,
    required CalmEyebrow eyebrow,
    required String illustrationName,
    required String title,
    required String body,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top 60 % — illustration placeholder
        Expanded(
          flex: 60,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgSunk(context),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              'ilustração: $illustrationName',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppColors.ink50(context),
              ),
            ),
          ),
        ),
        // Bottom 40 % — copy block padding 24
        Expanded(
          flex: 40,
          child: CalmCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                eyebrow,
                const SizedBox(height: 8),
                // Fraunces 32px hero — one per slide, lineheight 1.2, max 2 lines
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CalmText.display(context, size: 32),
                ),
                const SizedBox(height: 12),
                // 15px ink70 body, max 3 lines
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.ink70(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _SlideIndicator — inline ≤30 LoC
// Active dot = ink 24×8 pill; inactive = ink20 6×6 circle
// Drawn via CustomPainter — zero extra Containers / BoxDecorations
// ---------------------------------------------------------------------------

class _SlideIndicator extends StatelessWidget {
  const _SlideIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: CustomPaint(
        painter: _DotsPainter(
          count: count,
          current: current,
          inkColor: AppColors.ink(context),
          inactiveColor: AppColors.ink20(context),
        ),
        size: Size(count * 20 + 24.0, 8),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.count,
    required this.current,
    required this.inkColor,
    required this.inactiveColor,
  });

  final int count;
  final int current;
  final Color inkColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 6.0;
    const dotSize = 6.0;
    const pillWidth = 24.0;
    const pillHeight = 8.0;
    const radius = 4.0;

    // Total width for centering
    double totalW = 0;
    for (int i = 0; i < count; i++) {
      totalW += (i == current ? pillWidth : dotSize);
      if (i < count - 1) totalW += spacing;
    }
    double x = (size.width - totalW) / 2;

    final activePaint = Paint()..color = inkColor;
    final inactivePaint = Paint()..color = inactiveColor;

    for (int i = 0; i < count; i++) {
      if (i == current) {
        final rect = RRect.fromLTRBR(x, 0, x + pillWidth, pillHeight, const Radius.circular(radius));
        canvas.drawRRect(rect, activePaint);
        x += pillWidth;
      } else {
        final cy = (pillHeight - dotSize) / 2;
        canvas.drawCircle(Offset(x + dotSize / 2, cy + dotSize / 2), dotSize / 2, inactivePaint);
        x += dotSize;
      }
      if (i < count - 1) x += spacing;
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.count != count || old.current != current || old.inkColor != inkColor;
}
