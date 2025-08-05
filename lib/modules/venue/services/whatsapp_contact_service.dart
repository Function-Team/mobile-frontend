// File: lib/modules/shared/services/whatsapp_contact_service.dart
// UPDATE - Remove hardcoded fallback number

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';

class WhatsAppContactService {
  
  /// Contact host from venue detail page - PROPER VALIDATION
  static Future<void> contactHostFromVenue({
    required VenueModel venue,
  }) async {
    
    // Check if host exists
    if (venue.host == null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Host information not available',
        type: SnackbarType.error,
      );
      return;
    }

    // Check if host has phone number
    if (!venue.host!.hasPhone) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Host phone number not available',
        type: SnackbarType.error,
      );
      return;
    }

    final phoneNumber = venue.host!.phone!;
    final hostName = venue.host!.displayName;

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Contact Host',
      hostName: hostName,
      venueName: venue.name ?? 'Venue',
      phoneNumber: phoneNumber,
      isBookingContext: false,
    );

    if (confirmed) {
      final message = _generateVenueInquiryMessage(venue);
      await _openWhatsAppDirect(phoneNumber, message);
    }
  }

  /// Contact host from booking detail page - PROPER VALIDATION
  static Future<void> contactHostFromBooking({
    required BookingModel booking,
  }) async {
    
    // Check if booking has place and host
    if (booking.place?.host == null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Host information not available',
        type: SnackbarType.error,
      );
      return;
    }

    // Check if host has phone number
    if (!booking.place!.host!.hasPhone) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Host phone number not available',
        type: SnackbarType.error,
      );
      return;
    }

    final phoneNumber = booking.place!.host!.phone!;
    final hostName = booking.place!.host!.displayName;

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Contact Host',
      hostName: hostName,
      venueName: booking.place!.name ?? 'Venue',
      phoneNumber: phoneNumber,
      isBookingContext: true,
      bookingId: booking.id.toString(),
    );

    if (confirmed) {
      final message = _generateBookingMessage(booking);
      await _openWhatsAppDirect(phoneNumber, message);
    }
  }

  /// Show confirmation dialog before opening WhatsApp
  static Future<bool> _showConfirmationDialog({
    required String title,
    required String hostName,
    required String venueName,
    required String phoneNumber,
    required bool isBookingContext,
    String? bookingId,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.green[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Chat with $hostName on WhatsApp?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ll be redirected to WhatsApp. A message will be prepared for you.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    radius: 22,
                    child: Text(
                      hostName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hostName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          venueName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (isBookingContext && bookingId != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              'Booking #$bookingId',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              LocalizationHelper.tr(LocaleKeys.common_cancel),
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Confirm & Redirect Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Get.back(result: true),
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Open WhatsApp',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Open WhatsApp with message - SAME AS BEFORE
  static Future<void> _openWhatsAppDirect(
      String phoneNumber, String message) async {
    try {
      // Clean and format phone number
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final formattedPhone = cleanPhone.startsWith('0')
          ? '62${cleanPhone.substring(1)}'
          : cleanPhone.startsWith('62')
              ? cleanPhone
              : '62$cleanPhone';

      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl =
          Uri.parse('https://wa.me/$formattedPhone?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        CustomSnackbar.show(
          context: Get.context!,
          message: 'Opening WhatsApp...',
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          context: Get.context!,
          message: 'WhatsApp not installed on this device',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Failed to open WhatsApp',
        type: SnackbarType.error,
      );
    }
  }

  /// Generate venue inquiry message - SAME AS BEFORE
  static String _generateVenueInquiryMessage(VenueModel venue) {
    return '''Hi! I'm interested in your venue "${venue.name}".

📍 Location: ${venue.address ?? 'Not specified'}
👥 Capacity: ${venue.maxCapacity ?? 'Not specified'} people
💰 Price: ${venue.price != null ? 'Rp ${NumberFormat('#,###').format(venue.price)}/day' : 'Please inform'}

Could you please provide more information about:
• Availability for my preferred dates
• Detailed pricing and packages
• Booking procedures
• Any special requirements

Thank you for your time! 🙏''';
  }

  /// Generate booking specific message - SAME AS BEFORE
  static String _generateBookingMessage(BookingModel booking) {
    final venue = booking.place!;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return '''Hi! I'm contacting you regarding my booking at "${venue.name}".

 *Booking Details:*
• Booking ID: #${booking.id}
• Venue: ${venue.name}
• Date: ${dateFormat.format(booking.startDateTime)} - ${dateFormat.format(booking.endDateTime)}
• Time: ${timeFormat.format(booking.startDateTime)} - ${timeFormat.format(booking.endDateTime)}
• Status: ${booking.isConfirmed ? 'Confirmed' : ' Pending'}
• Payment: ${booking.paymentStatus == 'success' ? ' Paid' : ' Pending'}

I would like to discuss some details about my booking. Please let me know if you have any questions or if there's anything I need to prepare.

Thank you! 🙏''';
  }
}