import 'package:flutter/material.dart';

/// A reusable TextFormField widget
class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool showError;
  final String? errorText;
  final String?
  errorMessage;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? initialValue;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.showError = false,
    this.errorText,
    this.errorMessage,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = showError || errorText != null;
    final displayError = errorMessage ?? errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          validator: validator,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            labelStyle: const TextStyle(color: Colors.white70),
            // errorText: errorText,
            filled: true,
            fillColor: Colors.grey[900],
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        if (showError && displayError != null) ...[
          const SizedBox(height: 4),
          Text(
            displayError,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
