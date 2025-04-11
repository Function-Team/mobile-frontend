import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info, loading }

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      action: (actionLabel != null && onActionPressed != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onActionPressed,
              textColor: Colors.white,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success: return Icons.check_circle;
      case SnackbarType.error: return Icons.error;
      case SnackbarType.warning: return Icons.warning;
      case SnackbarType.info: return Icons.info;
      case SnackbarType.loading: return Icons.hourglass_top;
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success: return Colors.green;
      case SnackbarType.error: return Colors.red;
      case SnackbarType.warning: return Colors.amber;
      case SnackbarType.info: return Colors.blue;
      case SnackbarType.loading: return Colors.grey;
    }
  }
}
