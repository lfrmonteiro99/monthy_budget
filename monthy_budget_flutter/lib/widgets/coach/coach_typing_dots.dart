import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Three-dot typing indicator for the loading-reply state per SCREEN_ROLLOUT
/// §16 ("3 dots animados, NÃO shimmer"). Stagger 200ms per dot.
class CoachTypingDots extends StatefulWidget {
  const CoachTypingDots({super.key});

  @override
  State<CoachTypingDots> createState() => _CoachTypingDotsState();
}

class _CoachTypingDotsState extends State<CoachTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.ink50(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_controller.value + i / 3) % 1.0;
            final t = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * t;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.circle,
                size: 6,
                color: color.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
