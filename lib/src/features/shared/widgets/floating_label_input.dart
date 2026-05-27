import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/design_tokens.dart';

class FloatingLabelInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;
  final TextEditingController? controller;
  final VoidCallback? onToggleObscure;
  final VoidCallback? onPressedHint;
  final String? initialValue;
  final bool enabled;

  const FloatingLabelInput({
    super.key,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.inputFormatters = const [],
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onToggleObscure,
    this.onPressedHint,
    this.initialValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        color: kInputSurface,
        borderRadius: BorderRadius.circular(kRadiusInput),
        border: Border.all(color: kBorderFaint),
      ),
      child: Center(
        child: TextFormField(
          enabled: enabled,
          obscureText: obscureText,
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1,
          minLines: 1,
          scrollPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: kTextSecondary, size: 20),
            ),
            prefixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
            suffixIcon: (onToggleObscure ?? onPressedHint) != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kTextSecondary,
                        size: 20,
                      ),
                      onPressed: onToggleObscure ?? onPressedHint,
                    ),
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
            hintText: label,
            hintStyle: const TextStyle(
              color: kTextSecondary,
              fontSize: 13,
              overflow: TextOverflow.ellipsis,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
