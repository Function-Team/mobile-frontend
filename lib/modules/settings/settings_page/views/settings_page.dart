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
        title: Text(LocalizationHelper.tr('settings.title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Settings Section
              _buildSectionHeader(
                context,
                LocalizationHelper.tr('settings.account_settings'),
              ),
              const SizedBox(height: 8),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.edit_profile'),
                icon: Icons.person_outline,
                onTap: () => Get.toNamed(MyRoutes.editProfile),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.change_password'),
                icon: Icons.lock_outline,
                onTap: () {
                  // TODO: Navigate to Change Password Page
                  Get.snackbar(
                    LocalizationHelper.tr('common.info'),
                    'Change password feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionHeader(
                context,
                LocalizationHelper.tr('settings.preferences'),
              ),
              const SizedBox(height: 8),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.language'),
                icon: Icons.language_outlined,
                subtitle: _getCurrentLanguageName(),
                onTap: () => Get.to(() => const LanguageSettingsPage()),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.notification'),
                icon: Icons.notifications_outlined,
                onTap: () {
                  // TODO: Navigate to Notification Settings Page
                  Get.snackbar(
                    LocalizationHelper.tr('common.info'),
                    'Notification settings coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader(
                context,
                LocalizationHelper.tr('settings.about'),
              ),
              const SizedBox(height: 8),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.app_version'),
                icon: Icons.info_outline,
                trailing: Text(
                  '1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.privacy_policy'),
                icon: Icons.privacy_tip_outlined,
                onTap: () => Get.toNamed(MyRoutes.privacyPolicy),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.terms_conditions'),
                icon: Icons.description_outlined,
                onTap: () => Get.toNamed(MyRoutes.termsOfService),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                context: context,
                title: LocalizationHelper.tr('settings.about_us'),
                icon: Icons.business_outlined,
                onTap: () {
                  // TODO: Navigate to About Us Page
                  Get.snackbar(
                    LocalizationHelper.tr('common.info'),
                    'About us page coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),

              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutButton(context, authController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
    Color? textColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, AuthController authController) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, authController),
        icon: const Icon(Icons.logout),
        label: Text(LocalizationHelper.tr('settings.logout')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getCurrentLanguageName() {
    final currentLanguage = LocalizationHelper.getCurrentLanguageCode();
    return LocalizationHelper.getLanguageName(currentLanguage);
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationHelper.tr('settings.logout')),
          content: Text(LocalizationHelper.tr('auth.logout_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocalizationHelper.tr('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text(LocalizationHelper.tr('settings.logout')),
            ),
          ],
        );
      },
    );
  }
}
