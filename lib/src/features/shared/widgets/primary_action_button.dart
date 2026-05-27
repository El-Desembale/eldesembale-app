import 'package:flutter/material.dart';

import '../../../utils/design_tokens.dart';

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.arrow_forward,
    this.enabled = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 10),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(kRadiusButton),
      child: Container(
        height: kBtnHeight,
        margin: margin,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryGreen : kSurfaceSoft,
          borderRadius: BorderRadius.circular(kRadiusButton),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: Color(0x26173A25),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 22, right: 12),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled
                        ? kPrimaryGreenDeep
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: kFontBody,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: kBtnInnerWidth,
                height: kBtnInnerHeight,
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(kRadiusButton - 2),
                ),
                child: Icon(
                  icon,
                  color: enabled ? kPrimaryGreenDeep : Colors.white38,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
