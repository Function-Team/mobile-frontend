import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/texts/tr_text.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/modules/profile/views/faq_page.dart';
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
        title: LocalizationHelper.tr('profile.payment_methods'),
        subtitle: 'Add or remove payment methods',
        onTap: () {
          // Handle PAYMENT METHODS
        },
      ),
      const SizedBox(height: 16),
      _buildOptionTile(
        context: context,
        icon: Icons.person_outline,
        title: LocalizationHelper.tr('profile.your_details'),
        subtitle: 'Update your personal details',
        onTap: () {
          // Handle your details
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.money_off,
        title: LocalizationHelper.tr('profile.refunds'),
        subtitle: 'Request a refund',
        onTap: () {
          // Handle refunds
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.help_outline,
        title: LocalizationHelper.tr('faq.title'),
        subtitle: 'Frequently asked questions',
        onTap: () => Get.to(() => const FaqPage()),
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.headset_mic_outlined,
        title: LocalizationHelper.tr('contact_support.title'),
        subtitle: 'Get help with your account',
        onTap: () {
          // TODO: Navigate to contact support page
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.share,
        title: LocalizationHelper.tr('follow_us.title'),
        subtitle: 'Connect with us on social media',
        onTap: () {
          // TODO: Navigate to follow us page
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.info_outline,
        title: LocalizationHelper.tr('settings.about_us'),
        subtitle: 'Learn more about us',
        onTap: () {
          // Handle about us
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.settings_outlined,
        title: LocalizationHelper.tr('settings.title'),
        subtitle: LocalizationHelper.tr('settings.description'),
        onTap: () => controller.goToSettings(),
      ),
    ],
  );
}

Widget _buildOptionTiles({
  required BuildContext context,
  required IconData icon,
  required Widget titleWidget,
  required Widget subtitleWidget,
  required VoidCallback onTap,
}) {
  return Column(
    children: [
      ListTile(
        leading: Icon(icon),
        title: titleWidget,
        subtitle: subtitleWidget,
        onTap: onTap,
      ),
      const Divider(
        height: 0,
        thickness: 0.25,
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
      const Divider(
        height: 0,
        thickness: 0.25,
      ),
    ],
  );
}
