import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/texts/localized_text.dart';
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
        title: LocalizationHelper.t('profile.payment_methods'),
        subtitle: 'Add or remove payment methods',
        onTap: () {
          // Handle PAYMENT METHODS
        },
      ),
      const SizedBox(height: 16),
      _buildOptionTile(
        context: context,
        icon: Icons.person_outline,
        title: LocalizationHelper.t('profile.your_details'),
        subtitle: 'Update your personal details',
        onTap: () {
          // Handle your details
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.money_off,
        title: LocalizationHelper.t('profile.refunds'),
        subtitle: 'Request a refund',
        onTap: () {
          // Handle refunds
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.help_outline,
        title: LocalizationHelper.t('faq.title'),
        subtitle: 'Frequently asked questions',
        onTap: () => Get.to(() => const FaqPage()),
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.headset_mic_outlined,
        title: LocalizationHelper.t('contact_support.title'),
        subtitle: 'Get help with your account',
        onTap: () {
          // TODO: Navigate to contact support page
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.share,
        title: LocalizationHelper.t('follow_us.title'),
        subtitle: 'Connect with us on social media',
        onTap: () {
          // TODO: Navigate to follow us page
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.info_outline,
        title: LocalizationHelper.t('settings.about_us'),
        subtitle: 'Learn more about us',
        onTap: () {
          // Handle about us
        },
      ),
      _buildOptionTiles(
        context: context,
        icon: Icons.settings_outlined,
        titleWidget: const LocalizedText('settings.title'),
        subtitleWidget: const LocalizedText('settings.description'),
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
