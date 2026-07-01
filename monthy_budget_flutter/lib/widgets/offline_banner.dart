import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final String message;
  final int pendingCount;

  const OfflineBanner({
    super.key,
    this.message =
        'Offline mode: changes will sync when you regain connectivity.',
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning(context),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: AppColors.bg(context),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.bg(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (pendingCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: TextStyle(
                      color: AppColors.bg(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
