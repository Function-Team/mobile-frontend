import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';

class FollowUsBottomSheet extends StatelessWidget {
  const FollowUsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FollowUsBottomSheet(),
    );
  }

  Future<void> _launchUrl(
      BuildContext context, String url, String platformName) async {
    // Show confirmation dialog first
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            LocalizationHelper.trArgs(
              LocaleKeys.follow_us_openPlatform,
              {'platform': platformName},
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            LocalizationHelper.trArgs(
              LocaleKeys.follow_us_openPlatformMessage,
              {'platform': platformName},
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                LocalizationHelper.tr(LocaleKeys.common_cancel),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(LocalizationHelper.tr(LocaleKeys.common_open)),
            ),
          ],
        );
      },
    );

    // If user confirmed, launch the URL
    if (shouldProceed == true) {
      try {
        final Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            _showErrorSnackbar(context, platformName, url);
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackbar(context, platformName, url);
        }
      }
    }
  }

  void _showErrorSnackbar(
      BuildContext context, String platformName, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizationHelper.trArgs(
            LocaleKeys.follow_us_errorOpening,
            {'platform': platformName},
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: LocalizationHelper.tr(LocaleKeys.common_retry),
          textColor: Colors.white,
          onPressed: () async {
            // Retry opening the URL
            try {
              final Uri uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              // If retry fails, could show another message or just ignore
            }
          },
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Text(
            LocalizationHelper.tr(LocaleKeys.follow_us_title),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            LocalizationHelper.tr(LocaleKeys.follow_us_subtitle),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Social Media Cards
          _buildSocialCard(
            context,
            title: LocalizationHelper.tr(LocaleKeys.follow_us_instagram),
            subtitle:
                LocalizationHelper.tr(LocaleKeys.follow_us_instagramHandle),
            icon: FontAwesomeIcons.instagram,
            color: const Color(0xFFE4405F),
            onTap: () => _launchUrl(
              context,
              'https://www.instagram.com/function.venue',
              LocalizationHelper.tr(LocaleKeys.follow_us_instagram),
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialCard(
            context,
            title: LocalizationHelper.tr(LocaleKeys.follow_us_linkedin),
            subtitle:
                LocalizationHelper.tr(LocaleKeys.follow_us_linkedinHandle),
            icon: FontAwesomeIcons.linkedin,
            color: const Color(0xFF0077B5),
            onTap: () => _launchUrl(
              context,
              'https://www.linkedin.com/company/function-team/',
              LocalizationHelper.tr(LocaleKeys.follow_us_linkedin),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSocialCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
