import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FloatingActionButton(
        heroTag: heroTag,
        shape: const CircleBorder(),
        backgroundColor: UIColors.primeraGrey.withOpacity(0.15),
        onPressed: onPressed,
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
