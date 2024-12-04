import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfieldWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final void Function(String)? onChanged;
  final bool onlyNumber;
  const CustomTextfieldWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.onlyNumber,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType:
                      onlyNumber ? TextInputType.phone : TextInputType.name,
                  inputFormatters: onlyNumber
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : [],
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomDropDowndWidget extends StatelessWidget {
  final String hintText;
  final List<String> options;
  final void Function(String?)? onChanged;
  const CustomDropDowndWidget({
    super.key,
    required this.hintText,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              "     $hintText",
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: DropdownButtonFormField(
              hint: Text(
                hintText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              items: options.map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                filled: true,
                fillColor: Colors.transparent,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
              dropdownColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
