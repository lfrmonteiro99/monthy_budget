import 'package:flutter/material.dart';

import '../models/whats_new_entry.dart';
import '../theme/app_colors.dart';

class WhatsNewCard extends StatelessWidget {
  final WhatsNewEntry entry;
  final VoidCallback? onFeatureTap;

  const WhatsNewCard({
    super.key,
    required this.entry,
    this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'v${entry.version}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
                const Spacer(),
                if (entry.featureKey != null && onFeatureTap != null)
                  GestureDetector(
                    onTap: onFeatureTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Try it',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary(context),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary(context),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.body,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
