import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';

class LogoutBottomSheet extends StatelessWidget {
  final String? customImagePath;

  const LogoutBottomSheet({super.key, this.customImagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: 200,
              height: 150,
              child: customImagePath != null
                  ? Image.asset(
                      customImagePath!,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.logout,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),

            const SizedBox(height: 24),
            Text(
              LocalizationHelper.tr(LocaleKeys.settings_logout),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),
            Text(
              LocalizationHelper.tr(LocaleKeys.settings_logoutConfirmation),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    text: LocalizationHelper.tr(LocaleKeys.common_cancel),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    isLoading: false,
                    text: LocalizationHelper.tr(LocaleKeys.common_logout),
                    onPressed: () => Navigator.of(context).pop(true),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),

            // Bottom padding untuk safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }

  // Static method untuk menampilkan bottom sheet
  static Future<bool?> show(BuildContext context, {String? imagePath}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => LogoutBottomSheet(
        customImagePath: imagePath,
      ),
    );
  }
}
