import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:function_mobile/common/widgets/texts/localized_text.dart';
import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:get/get.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Debug current locale on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalizationHelper.debugCurrentLocale(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during loading
        return !_isLoading;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: LocalizedText('settings.language'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _isLoading ? null : () => Get.back(),
              ),
            ),
            body: _errorMessage != null
                ? _buildErrorView()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedText(
                          'settings.language',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LocalizedText(
                          'settings.language_description',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Current Language Display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.language,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LocalizedText(
                                      'settings.current_language',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    Text(
                                      '${LocalizationHelper.getLanguageFlag(context.locale.languageCode)} ${LocalizationHelper.getLanguageName(context.locale.languageCode)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        LocalizedText(
                          'settings.available_languages',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Language Options - Simplified!
                        ...AppConstants.supportedLocales.map((locale) {
                          final isSelected = context.locale.languageCode == locale.languageCode;
                          final languageName = LocalizationHelper.getLanguageName(locale.languageCode);
                          final languageFlag = LocalizationHelper.getLanguageFlag(locale.languageCode);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    languageFlag,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              title: Text(
                                languageName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                '${locale.languageCode.toUpperCase()}-${locale.countryCode}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : const Icon(Icons.radio_button_unchecked),
                              enabled: !_isLoading && !isSelected,
                              onTap: () {
                                if (!isSelected && !_isLoading) {
                                  _safeChangeLanguage(context, locale);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
          ),
          
          // Loading overlay (inside the Stack)
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        LocalizationHelper.t('common.loading'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Error view if translation files can't be loaded
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error Loading Languages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // Safe method to change language that won't crash the app
  void _safeChangeLanguage(BuildContext context, Locale locale) async {
    print("🔄 Attempting to change language to: ${locale.toString()}");
    print("🔄 Current locale: ${context.locale.toString()}");
    
    // Start with loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Simple approach: just change the locale and return
      await context.setLocale(locale);
      
      // Update controller if available
      try {
        final localizationController = Get.find<LocalizationController>();
        localizationController.updateLocale(locale.toString());
      } catch (e) {
        print("⚠️ Controller update failed: $e");
      }
      
      // Show success message and go back with a slight delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Safely check if widget is still mounted before accessing context
      if (!mounted) return;
      
      // Show success message
      Get.snackbar(
        LocalizationHelper.tr(context, 'common.success'),
        LocalizationHelper.trArgs(
          context, 
          'settings.language_changed', 
          {'language': LocalizationHelper.getLanguageName(locale.languageCode)}
        ),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
      
      // Go back to previous screen
      Get.back();
    } catch (e) {
      print("❌ Error changing language: $e");
      
      // Only update state if widget is still mounted
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to change language: $e";
      });
      
      // Show error message
      Get.snackbar(
        LocalizationHelper.tr(context, 'common.error'),
        'Failed to change language. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
}