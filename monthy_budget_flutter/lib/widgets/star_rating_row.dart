import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarRatingRow extends StatelessWidget {
  final int? currentRating;
  final ValueChanged<int> onRate;
  final double starSize;

  const StarRatingRow({
    super.key,
    this.currentRating,
    required this.onRate,
    this.starSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = currentRating != null && starValue <= currentRating!;
        return GestureDetector(
          onTap: () => onRate(starValue),
          child: Semantics(
            button: true,
            label: '$starValue star${starValue > 1 ? 's' : ''}',
            selected: isFilled,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                size: starSize,
                color: isFilled
                    ? Colors.amber
                    : AppColors.borderMuted(context),
              ),
            ),
          ),
        );
      }),
    );
  }
}
