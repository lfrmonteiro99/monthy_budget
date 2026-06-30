import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Composer text-field — bgSunk pill (radius 99), padding 12/18.
class ComposerInputField extends StatelessWidget {
  const ComposerInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    required this.enabled,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Single Container — radius 99 + bgSunk fill is the spec's input chrome.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSunk(context),
        borderRadius: BorderRadius.circular(99),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        enabled: enabled,
        textInputAction: TextInputAction.send,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(fontSize: 14, color: AppColors.ink(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.ink50(context),
            fontSize: 14,
          ),
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// 36×36 ink-filled send button with arrow_upward 18 bg. Disabled state
/// drops opacity to 0.4 per spec §16.
class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final inkBg = AppColors.ink(context);
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: inkBg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.bg(context),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: AppColors.bg(context),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
