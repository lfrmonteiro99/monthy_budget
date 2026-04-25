import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// A `TextFormField` wrapper preset to the Calm input spec.
///
/// Reads the global `inputDecorationTheme` (defined in `app_theme.dart`) and
/// only adds the convenience props every screen needs: optional [label],
/// [hint], [prefixIcon], [suffixIcon], and a [helper]/[errorText] line.
///
/// Surface, radius (14px), border colour, focused-border colour, hint colour
/// and content padding all come from the theme — never override them here.
///
/// Usage:
/// ```dart
/// CalmTextField(
///   label: 'Nome',
///   controller: _controller,
///   keyboardType: TextInputType.text,
/// )
///
/// CalmTextField(
///   label: 'Valor',
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
/// )
/// ```
class CalmTextField extends StatelessWidget {
  const CalmTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? initialValue;

  /// Floating label / static label above the input.
  final String? label;

  /// Hint text shown when the field is empty.
  final String? hint;

  /// Helper text rendered below the input in `ink50`.
  final String? helper;

  /// Error text rendered below the input in the theme error colour. When
  /// non-null, the border switches to the error treatment automatically.
  final String? errorText;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: AppColors.ink(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
      ),
    );
  }
}
