import 'package:flutter/material.dart';

class CustomUneditableWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String initialValue;
  const CustomUneditableWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Icon(
                  icon,
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextFormField(
                        initialValue: initialValue,
                        readOnly: true,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          fillColor: Colors.transparent,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
