import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/profile/views/faq_page.dart';
import 'package:function_mobile/modules/profile/widgets/follow_us_bottomsheets.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/profile/controllers/profile_options_controller.dart';
import 'package:function_mobile/modules/profile/controllers/profile_controller.dart';

Widget buildProfileOptions(BuildContext context, ProfileController profileController) {
  final ProfileOptionsController controller =
      Get.put(ProfileOptionsController());

  return Column(
    children: [
      // _buildOptionTile(
      //   context: context,
      //   icon: Icons.account_balance_wallet_outlined,
      //   title: LocalizationHelper.tr(LocaleKeys.profile_payment_methods),
      //   subtitle:
      //       LocalizationHelper.tr(LocaleKeys.profile_payment_methods_subtitle),
      //   onTap: () {
      //     // Handle PAYMENT METHODS
      //   },
      // ),
      // const SizedBox(height: 16),
      // _buildOptionTile(
      //   context: context,
      //   icon: Icons.person_outline,
      //   title: LocalizationHelper.tr(LocaleKeys.profile_your_details),
      //   subtitle:
      //       LocalizationHelper.tr(LocaleKeys.profile_your_details_subtitle),
      //   onTap: () {
      //     // Handle your details
      //   },
      // ),
      // _buildOptionTile(
      //   context: context,
      //   icon: Icons.money_off,
      //   title: LocalizationHelper.tr(LocaleKeys.profile_refunds),
      //   subtitle: LocalizationHelper.tr(LocaleKeys.profile_refunds_subtitle),
      //   onTap: () {
      //     // Handle refunds
      //   },
      // ),
      _buildOptionTile(
        context: context,
        icon: Icons.help_outline,
        title: LocalizationHelper.tr(LocaleKeys.faq_title),
        subtitle: LocalizationHelper.tr(LocaleKeys.faq_subtitle),
        onTap: () => Get.to(() => const FaqPage()),
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.headset_mic_outlined,
        title: LocalizationHelper.tr(LocaleKeys.contact_support_title),
        subtitle: LocalizationHelper.tr(LocaleKeys.contact_support_subtitle),
        onTap: () {
          // TODO: Navigate to contact support page
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.share,
        title: LocalizationHelper.tr(LocaleKeys.follow_us_title),
        subtitle: LocalizationHelper.tr(LocaleKeys.follow_us_subtitle),
        onTap: () {
          FollowUsBottomSheet.show(context);
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.info_outline,
        title: LocalizationHelper.tr(LocaleKeys.settings_about),
        subtitle: LocalizationHelper.tr(LocaleKeys.settings_about_subtitle),
        onTap: () {
          // Handle about us
        },
      ),
      _buildOptionTile(
        context: context,
        icon: Icons.settings_outlined,
        title: LocalizationHelper.tr(LocaleKeys.settings_settings),
        subtitle: LocalizationHelper.tr(LocaleKeys.settings_description),
        onTap: () => controller.goToSettings(),
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
