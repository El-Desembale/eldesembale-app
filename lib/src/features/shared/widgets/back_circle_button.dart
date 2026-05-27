import 'package:flutter/material.dart';

import '../../../utils/design_tokens.dart';

class BackCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? heroTag;

  const BackCircleButton({
    super.key,
    required this.onPressed,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          heroTag: heroTag,
          elevation: 0,
          shape: const CircleBorder(),
          backgroundColor: kSurfaceSoft,
          onPressed: onPressed,
          child: const Icon(
            Icons.arrow_back_rounded,
            color: kTextPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
