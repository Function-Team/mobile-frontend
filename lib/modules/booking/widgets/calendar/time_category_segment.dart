import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';

enum TimeCategory { morning, afternoon, evening }

class TimeCategorySegment extends StatelessWidget {
  final TimeCategory selectedCategory;
  final Function(TimeCategory) onCategoryChanged;

  const TimeCategorySegment({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: TimeCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCategoryChanged(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Get.theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Get.theme.primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _getCategoryLabel(category),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryLabel(TimeCategory category) {
    switch (category) {
      case TimeCategory.morning:
        return LocalizationHelper.tr(LocaleKeys.common_morning);
      case TimeCategory.afternoon:
        return LocalizationHelper.tr(LocaleKeys.common_afternoon);
      case TimeCategory.evening:
        return LocalizationHelper.tr(LocaleKeys.common_evening);
    }
  }
}

// Helper class for time category utilities
class TimeCategoryHelper {
  static bool isSlotInCategory(String slotStartTime, TimeCategory category) {
    final hour = _parseHour(slotStartTime);

    switch (category) {
      case TimeCategory.morning:
        return hour >= 6 && hour < 12; // 6 AM - 11:59 AM
      case TimeCategory.afternoon:
        return hour >= 12 && hour < 18; // 12 PM - 5:59 PM
      case TimeCategory.evening:
        return hour >= 18 && hour <= 22; // 6 PM - 10 PM
    }
  }

  static DateTimeRange getCategoryTimeRange(TimeCategory category, DateTime selectedDate) {
    switch (category) {
      case TimeCategory.morning:
        return DateTimeRange(
          start: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 6, 0),
          end: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 11, 59),
        );
      case TimeCategory.afternoon:
        return DateTimeRange(
          start: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 12, 0),
          end: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 17, 59),
        );
      case TimeCategory.evening:
        return DateTimeRange(
          start: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 18, 0),
          end: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 22, 0),
        );
    }
  }

  static String getCategoryForTime(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 12) return 'Pagi';
    if (hour >= 12 && hour < 18) return 'Siang';
    return 'Malam';
  }

  static int _parseHour(String timeString) {
    final parts = timeString.split(':');
    return int.parse(parts[0]);
  }
}