import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? rightIcon;
  final IconData? leftIcon;
  final double? width;
  final double? height;
  final double? paddingHorizontal;
  final double? paddingVertical;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.rightIcon,
    this.leftIcon,
    this.width,
    this.height = 50,
    this.paddingHorizontal,
    this.paddingVertical,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
              if (leftIcon != null) ...[
                Icon(leftIcon,
                    size: 16, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(width: 8),
              ],
              Text(text),
              if (rightIcon != null) ...[
                const SizedBox(width: 8),
                Icon(rightIcon,
                    size: 16, color: Theme.of(context).colorScheme.onPrimary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
