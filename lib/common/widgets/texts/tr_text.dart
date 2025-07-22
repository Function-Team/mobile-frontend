import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:get/get.dart';

/// A simplified Text widget that automatically translates and rebuilds when language changes
/// Usage: TrText('settings.title') instead of Text(LocalizationHelper.tr('settings.title'))
class TrText extends StatelessWidget {
  /// The translation key
  final String translationKey;
  
  /// Optional text style
  final TextStyle? style;
  
  /// Optional text alignment
  final TextAlign? textAlign;
  
  /// Optional text overflow
  final TextOverflow? overflow;
  
  /// Optional maximum number of lines
  final int? maxLines;
  
  /// Optional softWrap value
  final bool? softWrap;
  
  /// Optional arguments for parameterized translations
  final Map<String, String>? args;
  
  /// Optional plural count for plural translations
  final int? pluralCount;

  const TrText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.args,
    this.pluralCount,
  });

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    
    return Obx(() {
      // This will rebuild when language changes
      final _ = localizationController.currentLocale.value;
      
      // Get the translated text
      String translatedText;
      if (pluralCount != null) {
        translatedText = LocalizationHelper.trPlural(translationKey, pluralCount!);
      } else if (args != null) {
        translatedText = LocalizationHelper.trArgs(translationKey, args!);
      } else {
        translatedText = LocalizationHelper.tr(translationKey);
      }
      
      return Text(
        translatedText,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
      );
    });
  }
}

/// Extension for easy translation access on strings
extension StringTranslation on String {
  /// Translate this string as a key
  String get tr => LocalizationHelper.tr(this);
  
  /// Translate with arguments
  String trArgs(Map<String, String> args) => LocalizationHelper.trArgs(this, args);
  
  /// Translate with plural
  String trPlural(int count) => LocalizationHelper.trPlural(this, count);
}