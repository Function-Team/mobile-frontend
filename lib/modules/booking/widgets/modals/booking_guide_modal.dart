import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';

class BookingGuideModal {
  static void show() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
            maxWidth: Get.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: Get.theme.primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        LocalizationHelper.tr(LocaleKeys.bookingGuide_title),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: _buildGuideContent(),
                ),
              ),

              // Footer
              Container(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      LocalizationHelper.tr(LocaleKeys.bookingGuide_gotIt),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _buildGuideContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Select Date
        _buildGuideStep(
          stepNumber: 1,
          title: LocalizationHelper.tr(LocaleKeys.bookingGuide_step1Title),
          description: LocalizationHelper.tr(LocaleKeys.bookingGuide_step1Description),
          content: Column(
            children: [
              SizedBox(height: 8),
              _buildGuideLegendItem(Colors.green[50]!, Colors.green[300]!, LocalizationHelper.tr(LocaleKeys.bookingGuide_availableDates)),
              _buildGuideLegendItem(Colors.orange[50]!, Colors.orange[300]!, LocalizationHelper.tr(LocaleKeys.bookingGuide_limitedAvailability)),
              _buildGuideLegendItem(Colors.red[50]!, Colors.red[300]!, LocalizationHelper.tr(LocaleKeys.bookingGuide_fullyBooked)),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Step 2: Choose Time Category
        _buildGuideStep(
          stepNumber: 2,
          title: LocalizationHelper.tr(LocaleKeys.bookingGuide_step2Title),
          description: LocalizationHelper.tr(LocaleKeys.bookingGuide_step2Description),
          content: Column(
            children: [
              SizedBox(height: 8),
              _buildTimeCategoryExample(LocalizationHelper.tr(LocaleKeys.common_morning), LocalizationHelper.tr(LocaleKeys.bookingGuide_morningTime), Colors.blue),
              _buildTimeCategoryExample(LocalizationHelper.tr(LocaleKeys.common_afternoon), LocalizationHelper.tr(LocaleKeys.bookingGuide_afternoonTime), Colors.orange),
              _buildTimeCategoryExample(LocalizationHelper.tr(LocaleKeys.common_evening), LocalizationHelper.tr(LocaleKeys.bookingGuide_eveningTime), Colors.purple),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Step 3: Select Time Slots
        _buildGuideStep(
          stepNumber: 3,
          title: LocalizationHelper.tr(LocaleKeys.bookingGuide_step3Title),
          description: LocalizationHelper.tr(LocaleKeys.bookingGuide_step3Description),
          content: Column(
            children: [
              SizedBox(height: 8),
              _buildGuideFeature(LocalizationHelper.tr(LocaleKeys.bookingGuide_feature1)),
              _buildGuideFeature(LocalizationHelper.tr(LocaleKeys.bookingGuide_feature2)),
              _buildGuideFeature(LocalizationHelper.tr(LocaleKeys.bookingGuide_feature3)),
              _buildGuideFeature(LocalizationHelper.tr(LocaleKeys.bookingGuide_feature4)),
              SizedBox(height: 12),
              _buildSlotGuideExample(),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Step 4: Cross-category booking
        _buildGuideStep(
          stepNumber: 4,
          title: LocalizationHelper.tr(LocaleKeys.bookingGuide_step4Title),
          description: LocalizationHelper.tr(LocaleKeys.bookingGuide_step4Description),
          content: Column(
            children: [
              SizedBox(height: 8),
              _buildGuideLegendItem(Colors.purple[50]!, Colors.purple[300]!, LocalizationHelper.tr(LocaleKeys.bookingGuide_connectableSlots)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timeline, color: Colors.orange[600], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LocalizationHelper.tr(LocaleKeys.bookingGuide_rangeContinues),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Final tip
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[600], size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${LocalizationHelper.tr(LocaleKeys.bookingGuide_tipTitle)} ${LocalizationHelper.tr(LocaleKeys.bookingGuide_tipDescription)}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildGuideStep({
    required int stepNumber,
    required String title,
    required String description,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        SizedBox(height: 8),
        content,
      ],
    );
  }

  static Widget _buildGuideLegendItem(Color bgColor, Color borderColor, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor),
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTimeCategoryExample(String name, String time, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGuideFeature(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  static Widget _buildSlotGuideExample() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationHelper.tr(LocaleKeys.bookingGuide_example),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildMiniSlot('8:00-9:00', Colors.green[50]!, Colors.green[300]!),
              SizedBox(width: 4),
              _buildMiniSlot('9:00-10:00', Colors.green[50]!, Colors.green[300]!),
              SizedBox(width: 4),
              _buildMiniSlot('10:00-11:00', Get.theme.primaryColor, Get.theme.primaryColor, true),
            ],
          ),
          SizedBox(height: 4),
          Text(
            LocalizationHelper.tr(LocaleKeys.bookingGuide_exampleDescription),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMiniSlot(String text, Color bgColor, Color borderColor, [bool isSelected = false]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }
}