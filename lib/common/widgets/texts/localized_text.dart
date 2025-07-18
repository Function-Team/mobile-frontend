import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:get/get.dart';

/// A Text widget that automatically rebuilds when the app language changes
class LocalizedText extends StatefulWidget {
  /// The translation key to use
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

  const LocalizedText(
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
  State<LocalizedText> createState() => _LocalizedTextState();
}

class _LocalizedTextState extends State<LocalizedText> {
  // Get the localization controller to track locale changes
  late final LocalizationController _localizationController;
  
  @override
  void initState() {
    super.initState();
    // Get or create localization controller
    _localizationController = Get.find<LocalizationController>();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track locale changes
    context.locale;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // This will rebuild when _localizationController.currentLocale changes
      final _ = _localizationController.currentLocale.value;
      
      // Translate the text based on the type of translation needed
      String translatedText;
      
      if (widget.pluralCount != null) {
        // Plural translation
        translatedText = easy.StringTranslateExtension(widget.translationKey).plural(widget.pluralCount!);
      } else if (widget.args != null) {
        // Translation with arguments
        translatedText = easy.StringTranslateExtension(widget.translationKey).tr(namedArgs: widget.args!);
      } else {
        // Simple translation
        translatedText = easy.StringTranslateExtension(widget.translationKey).tr();
      }
      
      return Text(
        translatedText,
        style: widget.style,
        textAlign: widget.textAlign,
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        softWrap: widget.softWrap,
      );
    });
  }
}