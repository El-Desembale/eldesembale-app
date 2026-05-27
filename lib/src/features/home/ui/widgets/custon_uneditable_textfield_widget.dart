import 'package:flutter/material.dart';

import '../../../../utils/design_tokens.dart';

class CustomUneditableWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String initialValue;
  final Widget? leading;
  final bool singleLineValue;

  const CustomUneditableWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.initialValue,
    this.leading,
    this.singleLineValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kInputSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorderFaint),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: leading != null
                ? const EdgeInsets.symmetric(horizontal: 8)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: kSurfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: leading ??
                  Icon(
                    icon,
                    color: kTextPrimary,
                    size: 20,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  initialValue,
                  maxLines: singleLineValue ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
