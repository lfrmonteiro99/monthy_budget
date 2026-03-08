import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InfoIconButton extends StatelessWidget {
  final String title;
  final String body;

  const InfoIconButton({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'More info about $title',
      child: InkWell(
        onTap: () => _showSheet(context),
        customBorder: const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.textMuted(context),
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.surface(context),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close,
                      size: 20, color: AppColors.textMuted(ctx)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(ctx),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
