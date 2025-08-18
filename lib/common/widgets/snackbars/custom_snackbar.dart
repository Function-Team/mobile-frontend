import 'dart:async';
import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info, loading }

class CustomSnackbar {
  // Static debounce timers for different message types
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, String> _lastMessages = {};

  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool autoClear = true,
    bool enableDebounce = false,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) {
    // Auto-clear existing snackbars if enabled
    if (autoClear) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    // Handle debouncing if enabled
    if (enableDebounce) {
      final debounceKey = '${type.toString()}_$message';
      
      // Cancel previous timer for this message type
      _debounceTimers[debounceKey]?.cancel();
      
      // Check if same message was recently shown
      if (_lastMessages[debounceKey] == message) {
        return; // Skip duplicate messages
      }
      
      // Set up new debounce timer
      _debounceTimers[debounceKey] = Timer(debounceDuration, () {
        _lastMessages[debounceKey] = message;
        _showSnackBar(context, message, type, actionLabel, onActionPressed);
        
        // Clear the message after some time to allow future duplicates
        Timer(const Duration(seconds: 2), () {
          _lastMessages.remove(debounceKey);
        });
      });
      
      return;
    }

    // Show immediately if no debouncing
    _showSnackBar(context, message, type, actionLabel, onActionPressed);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    SnackbarType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
  ) {
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
      duration: _getDuration(type),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Clear all debounce timers (useful for cleanup)
  static void clearDebounceTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _lastMessages.clear();
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

  static Duration _getDuration(SnackbarType type) {
    switch (type) {
      case SnackbarType.error: return const Duration(seconds: 4); 
      case SnackbarType.warning: return const Duration(seconds: 3);
      case SnackbarType.success: return const Duration(seconds: 2);
      case SnackbarType.info: return const Duration(seconds: 2);
      case SnackbarType.loading: return const Duration(seconds: 1);
    }
  }
}
