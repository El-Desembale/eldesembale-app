import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({
    super.key,
    required this.onChanged,
  });

  final void Function(String) onChanged;
  @override
  _OtpInputWidgetState createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void nextField(String value, int index) {
    if (index == 5) {
      widget.onChanged(controllers.map((e) => e.text).join());
    }
    if (value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 47,
          child: TextFormField(
            style: const TextStyle(color: Colors.white, fontSize: 24),
            controller: controllers[index],
            focusNode: focusNodes[index],
            autofocus: index == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              fillColor: Colors.white.withOpacity(0.16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            onChanged: (value) => nextField(value, index),
          ),
        );
      }),
    );
  }
}
