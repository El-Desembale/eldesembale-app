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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.black : Colors.white.withOpacity(0.4),
                  fontSize: kFontBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: kBtnInnerWidth,
                height: kBtnInnerHeight,
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(kRadiusButton - 2),
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
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
