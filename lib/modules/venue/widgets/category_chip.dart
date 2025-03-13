// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;
  final bool? isBackground;

  const CategoryChip({
    required this.label,
    this.icon,
    super.key,
    this.color,
    this.iconColor,
    this.isBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      avatar: icon != null
          ? Icon(
              icon,
              size: 12,
              color: iconColor ?? theme.colorScheme.tertiary,
            )
          : null,
      backgroundColor: isBackground == true
          ? color?.withOpacity(0.1) ??
              theme.colorScheme.onSurface.withOpacity(0.1)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      side: BorderSide(
        color: color ?? theme.primaryColor,
        width: 0.5,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.all(6),
      visualDensity: VisualDensity.compact,
    );
  }
}
