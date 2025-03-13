import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? paddingHorizontal;
  final double? paddingVertical;

  const SecondaryButton({
    required this.text,
    required this.onPressed,
    this.textColor,
    this.width,
    this.height = 50,
    this.paddingHorizontal,
    this.paddingVertical,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal ?? 0,
              vertical: paddingVertical ?? 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
