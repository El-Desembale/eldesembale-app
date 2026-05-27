import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/design_tokens.dart';

class CustomListTile extends StatelessWidget {
  final String leadingIcon;
  final String title;
  final String subTitle;
  final IconData trailingIcon;
  final Function()? onTap;
  final bool isCompleted;
  const CustomListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.trailingIcon,
    required this.onTap,
    required this.isCompleted,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kRadiusCard),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isCompleted ? kPrimaryGreenSoft : kSurfaceSoft,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(
            color: isCompleted
                ? kPrimaryGreen.withValues(alpha: 0.4)
                : kBorderFaint,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    leadingIcon,
                    colorFilter: isCompleted
                        ? const ColorFilter.mode(kPrimaryGreen, BlendMode.srcIn)
                        : null,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isCompleted ? kPrimaryGreen : kTextPrimary,
                            fontSize: 15.0,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCompleted)
                          Text(
                            subTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 12.0,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isCompleted
                ? const Icon(Icons.check_circle, color: kPrimaryGreen, size: 24)
                : Icon(trailingIcon, color: kTextSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}
