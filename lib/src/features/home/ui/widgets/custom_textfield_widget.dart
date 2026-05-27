import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../utils/design_tokens.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: kInputSurface,
        borderRadius: BorderRadius.circular(kRadiusInput),
        border: Border.all(color: kBorderFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(color: kTextSecondary),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            keyboardType: onlyNumber ? TextInputType.phone : TextInputType.name,
            inputFormatters:
                onlyNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
            onChanged: onChanged,
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
        color: kInputSurface,
        borderRadius: BorderRadius.circular(kRadiusInput),
        border: Border.all(color: kBorderFaint),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              "     $hintText",
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: DropdownButtonFormField(
              hint: Text(
                hintText,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 15,
                ),
              ),
              items: options.map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 15,
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
                color: kTextPrimary,
                fontSize: 15,
              ),
              dropdownColor: kBgScreenAlt,
            ),
          ),
        ],
      ),
    );
  }
}
