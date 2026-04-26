import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// A Calm-styled row containing a title, optional subtitle, and a trailing
/// `Switch`. Replaces raw `SwitchListTile` for settings-style toggles.
///
/// Layout (vertical 12px padding):
/// ```
/// [title 15px w500 ink]               [Switch]
/// [subtitle 13px ink50 — optional ]
/// ```
///
/// The widget ships with no background — wrap multiple in a `CalmCard` and
/// separate them with `Divider(color: AppColors.line(context), height: 1)`.
class CalmSwitchRow extends StatelessWidget {
  const CalmSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leadingIcon,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink(context);
    final ink50 = AppColors.ink50(context);
    return InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 20, color: enabled ? ink : ink50),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: enabled ? ink : ink50,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13, color: ink50),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
