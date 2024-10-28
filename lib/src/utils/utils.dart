import 'package:flutter/material.dart';

import 'colors.dart';

class Utils {
  static InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 15,
      ),
      filled: true,
      fillColor: UIColors.primaryBlack,
      hintText: label,
      hintStyle: const TextStyle(
        color: UIColors.primaryTextColor,
        fontSize: 16.0,
      ),
      border: customImputBorder(),
      enabledBorder: customImputBorder(),
      focusedBorder: customImputBorder(),
    );
  }

  static InputDecoration customDecoration(String label, String? imagePath) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 15,
      ),
      filled: true,
      fillColor: UIColors.primaryBlack,
      hintText: label,
      hintStyle: const TextStyle(
        color: UIColors.primaryTextColor,
        fontSize: 18.0,
      ),
      suffixIcon: imagePath != null ? Image.asset(imagePath) : null,
      border: customImputBorder(),
      enabledBorder: customImputBorder(),
      focusedBorder: customImputBorder(),
    );
  }

  static ElevatedButton defaultButton(String text, Function() onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: UIColors.primaryBlack,
        side: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: UIColors.primaryTextColor,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Container greenWithShadowYellowButton(
      String text, Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: UIColors.secondaryYellow,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: UIColors.primaryColorButton,
          shadowColor: UIColors.secondaryYellow,
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static ElevatedButton secondaryButton(String text, Function() onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: UIColors.primaryYellow,
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        shadowColor: Colors.white,
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
    );
  }

  static Decoration defaultContainerDecoration() {
    return BoxDecoration(
      color: UIColors.primaryBlack,
      borderRadius: BorderRadius.circular(25.0),
      border: Border.all(
        color: Colors.black,
        width: 2,
      ),
    );
  }
}

InputBorder customImputBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color.fromARGB(128, 0, 0, 0),
      width: 4,
    ),
    borderRadius: BorderRadius.circular(15.0),
  );
}
