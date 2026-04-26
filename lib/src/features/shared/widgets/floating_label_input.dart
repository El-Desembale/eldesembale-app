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
      height: 52,
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(kRadiusInput),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
          style: const TextStyle(color: kTextPrimary, fontSize: 15),
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: Colors.white38, size: 20),
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
                        color: Colors.white30,
                        size: 20,
                      ),
                      onPressed: onToggleObscure ?? onPressedHint,
                    ),
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
            hintText: label,
            hintStyle:
                TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
