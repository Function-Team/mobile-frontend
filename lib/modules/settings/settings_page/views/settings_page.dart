import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/profile/views/language_settings_page.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
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
        title: Text(LocalizationHelper.tr(context, 'settings.title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocalizationHelper.tr(context, 'settings.account_settings')),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.edit_profile'),
                onTap: () => Get.toNamed(MyRoutes.editProfile),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.change_password'),
                onTap: () {
                  // Navigate to Change Password Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              const SizedBox(height: 16),
              Text(LocalizationHelper.tr(context, 'settings.preferences')),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.language'),
                onTap: () => Get.to(() => const LanguageSettingsPage()),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.notification'),
                onTap: () {
                  // Navigate to Notification Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              const SizedBox(height: 16),
              Text(LocalizationHelper.tr(context, 'settings.about')),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.app_version'),
                trailing: const Text('1.0.0'),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.privacy_policy'),
                onTap: () => Get.toNamed(MyRoutes.privacyPolicy),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.terms_of_service'),
                onTap: () => Get.toNamed(MyRoutes.termsOfService),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'settings.about_us'),
                onTap: () {
                  // Navigate to About Us Page
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              const SizedBox(height: 16),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr(context, 'logout'),
                onTap: () => authController.showLogoutConfirmation(),
                textColor: Theme.of(context).colorScheme.error,
                trailing: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
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
    Color? textColor,
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      trailing: trailing,
      textColor: textColor,
    );
  }
}