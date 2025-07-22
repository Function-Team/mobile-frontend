import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/profile/views/language_settings_page.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart'; // TAMBAHKAN
import 'package:get/get.dart';
import 'package:function_mobile/common/routes/routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            Text(LocalizationHelper.tr(LocaleKeys.settings_settings)), // FIXED
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.settings_account), // FIXED
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildSettingsItem(
                context: context,
                title:
                    LocalizationHelper.tr(LocaleKeys.settings_profile), // FIXED
                onTap: () => Get.toNamed(MyRoutes.editProfile),
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.person_outline,
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(
                    LocaleKeys.settings_changePassword), // FIXED
                onTap: () {
                  // Navigate to Change Password Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.lock_outline,
              ),

              const SizedBox(height: 16),
              const Divider(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocalizationHelper.tr(
                      LocaleKeys.settings_preferences), // FIXED
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(
                    LocaleKeys.settings_language), // FIXED
                onTap: () => Get.to(() => const LanguageSettingsPage()),
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.language,
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(
                    LocaleKeys.settings_notifications), // FIXED
                onTap: () {
                  // Navigate to Notification Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.notification_add_outlined,
              ),
              _buildSettingsItem(
                context: context,
                title:
                    LocalizationHelper.tr(LocaleKeys.settings_theme), // FIXED
                onTap: () {
                  // Navigate to Theme Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.palette_outlined,
              ),

              const SizedBox(height: 16),
              const Divider(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.settings_help), // FIXED
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(LocaleKeys.settings_faq), // FIXED
                onTap: () {
                  // Navigate to FAQ Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.help_outline,
              ),
              _buildSettingsItem(
                context: context,
                title:
                    LocalizationHelper.tr(LocaleKeys.settings_support), // FIXED
                onTap: () {
                  // Navigate to Support Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.headset_mic_outlined,
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(
                    LocaleKeys.settings_contactUs), // FIXED
                onTap: () {
                  // Navigate to Contact Us Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.contact_support_outlined,
              ),

              const SizedBox(height: 16),
              const Divider(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.settings_about), // FIXED
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildSettingsItem(
                context: context,
                title:
                    LocalizationHelper.tr(LocaleKeys.settings_version), // FIXED
                trailing: const Text('1.0.0'),
                icon: Icons.info_outline,
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(
                    LocaleKeys.settings_privacyPolicy), // FIXED
                onTap: () => Get.toNamed(MyRoutes.privacyPolicy),
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.privacy_tip_outlined,
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(
                    LocaleKeys.settings_termsOfService), // FIXED
                onTap: () => Get.toNamed(MyRoutes.termsOfService),
                trailing: const Icon(Icons.keyboard_arrow_right),
                icon: Icons.description_outlined,
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      authController.showLogoutConfirmation();
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      LocalizationHelper.tr(
                          LocaleKeys.settings_logout), // FIXED
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: Theme.of(context).primaryColor)
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationHelper.tr(LocaleKeys.settings_logout)), // FIXED
        content: Text(LocalizationHelper.tr(
            LocaleKeys.settings_logoutConfirmation)), // FIXED
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text(LocalizationHelper.tr(LocaleKeys.common_cancel)), // FIXED
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authController.logout();
            },
            child: Text(
              LocalizationHelper.tr(LocaleKeys.settings_logout), // FIXED
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
