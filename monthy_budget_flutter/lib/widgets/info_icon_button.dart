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
        title: title,
        child: Text(
          body,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.ink70(ctx),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
