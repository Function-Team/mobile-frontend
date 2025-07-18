import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr('settings.language')),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.tr('settings.choose_language'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.tr('settings.language_description'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // English Option
            _buildLanguageOption(
              context: context,
              languageCode: 'en',
              languageName: 'English',
              flag: '🇺🇸',
              isSelected: context.locale.languageCode == 'en',
            ),
            
            const SizedBox(height: 12),
            
            // Indonesian Option
            _buildLanguageOption(
              context: context,
              languageCode: 'id',
              languageName: 'Bahasa Indonesia',
              flag: '🇮🇩',
              isSelected: context.locale.languageCode == 'id',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          languageName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : const Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
              ),
        onTap: isSelected 
            ? null 
            : () => _showLanguageChangeDialog(context, languageCode, languageName),
      ),
    );
  }

  void _showLanguageChangeDialog(BuildContext context, String languageCode, String languageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationHelper.tr('settings.change_language')),
          content: Text(
            LocalizationHelper.trArgs(
              'settings.change_language_confirm',
              {'language': languageName},
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocalizationHelper.tr('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call the language change
                LocalizationHelper.changeLanguage(context, languageCode);
              },
              child: Text(LocalizationHelper.tr('common.change')), 
            ),
          ],
        );
      },
    );
  }
}