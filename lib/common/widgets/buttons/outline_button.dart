import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OutlineButton extends StatelessWidget {
  final String text;
  final String? textSize;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool useFaIcon; // Tambahkan flag untuk FaIcon
  final Color? textColor;
  final Color? outlineColor;

  const OutlineButton({
    super.key,
    required this.text,
    this.textSize,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
    this.useFaIcon = false, // Default pakai Icon biasa
    this.textColor,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(
              color: outlineColor ?? Theme.of(context).colorScheme.primary,
              width: 0.5,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    useFaIcon ? FaIcon(icon, size: 20) : Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: textSize != null ? double.parse(textSize!) : 16,
                      color: textColor ?? Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
