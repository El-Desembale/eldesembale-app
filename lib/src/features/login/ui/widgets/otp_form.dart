import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({super.key, required this.onChanged});
  final void Function(String) onChanged;

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    if (index == 5 || (value.length == 1 && index == 5)) {
      widget.onChanged(_controllers.map((c) => c.text).join());
    }
    if (index < 5 && value.length == 1) {
      widget.onChanged(_controllers.map((c) => c.text).join());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 47,
          child: TextFormField(
            style: const TextStyle(color: Colors.white, fontSize: 24),
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            autofocus: i == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              fillColor: Colors.white.withOpacity(0.12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color.fromRGBO(47, 255, 0, 1)),
              ),
            ),
            onChanged: (v) => _onChanged(v, i),
          ),
        );
      }),
    );
  }
}

class OtpResendButton extends StatelessWidget {
  final int timerSeconds;
  final VoidCallback? onResend;

  const OtpResendButton({
    super.key,
    required this.timerSeconds,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (timerSeconds > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Reenviar código en ${timerSeconds}s',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 13,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onResend,
        icon: const Icon(Icons.refresh_outlined,
            size: 18, color: Color.fromRGBO(47, 255, 0, 1)),
        label: const Text(
          'Reenviar código',
          style: TextStyle(
            color: Color.fromRGBO(47, 255, 0, 1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color.fromRGBO(47, 255, 0, 1)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
