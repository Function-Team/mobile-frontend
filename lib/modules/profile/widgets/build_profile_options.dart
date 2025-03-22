import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/profile/controllers/profile_options_controller.dart';

Widget buildProfileOptions(BuildContext context) {
  final ProfileOptionsController controller =
      Get.put(ProfileOptionsController());

  return Column(
    children: [
      _buildOptionTile(
        context: context,
        icon: Icons.account_balance_wallet_outlined,
        title: 'Payment Methods',
        subtitle: 'Add or remove payment methods',
        onTap: () {
          // Handle PAYMENT METHODS
        },
      ),
      SizedBox(height: 16),
      _buildOptionTile(
        context: context,
        icon: Icons.person_outline,
        title: 'Your Details',
        subtitle: 'Update your personal details',
        onTap: () {
          // Handle your details
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.money_off,
        title: 'Refunds',
        subtitle: 'Request a refund',
        onTap: () {
          // Handle refunds
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy',
        subtitle: 'View our privacy policy',
        onTap: () {
          // Handle privacy
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help with your account',
        onTap: () {
          // Handle help & support
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.headset_mic_outlined,
        title: 'Contact Us',
        subtitle: 'Get in touch with us',
        onTap: () {
          // Handle contact us
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.info_outline,
        title: 'About Us',
        subtitle: 'Learn more about us',
        onTap: () {
          // Handle about us
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'Manage your account settings',
        onTap: () {
          controller.goToSettings();
        },
      ),
    ],
  );
}

Widget _buildOptionTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Column(
    children: [
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
      Divider(
        height: 0,
        thickness: 0.25,
      ),
    ],
  );
}
