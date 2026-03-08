import 'package:flutter/material.dart';

import '../models/roadmap_entry.dart';
import '../theme/app_colors.dart';

class RoadmapLaneSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<RoadmapEntry> entries;

  const RoadmapLaneSection({
    super.key,
    required this.title,
    required this.icon,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...entries.map((entry) => _RoadmapTile(entry: entry)),
      ],
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  final RoadmapEntry entry;

  const _RoadmapTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isHighlighted
              ? AppColors.primary(context).withValues(alpha: 0.4)
              : AppColors.border(context),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.isHighlighted)
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.primary(context),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
