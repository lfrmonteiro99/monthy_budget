import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'calm/calm.dart';

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
              color: AppColors.ink50(context),
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    CalmBottomSheet.show(
      context,
      builder: (ctx) => CalmBottomSheetContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink(ctx),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.ink50(ctx)),
                  onPressed: () => Navigator.of(ctx).pop(),
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.ink70(ctx),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
