import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isrightIcon;

  const CustomTextButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.icon,
      this.isrightIcon = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            if (!isrightIcon && icon != null)
              Icon(icon, color: Theme.of(context).primaryColor, size: 15),
            Text(text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
            if (isrightIcon && icon != null)
              Icon(icon, color: Theme.of(context).primaryColor, size: 15),
          ],
        ));
  }
}
