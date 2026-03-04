import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  static const _green = Color.fromRGBO(47, 255, 0, 1);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.0),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color.fromRGBO(47, 255, 0, 0.08)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(
            color: isCompleted
                ? _green.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
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
                        ? const ColorFilter.mode(_green, BlendMode.srcIn)
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
                            color: isCompleted ? _green : Colors.white,
                            fontSize: 16.0,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (isCompleted)
                          Text(
                            subTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isCompleted
                ? const Icon(Icons.check_circle, color: _green, size: 28)
                : Icon(trailingIcon, color: Colors.white.withOpacity(0.5), size: 28),
          ],
        ),
      ),
    );
  }
}
