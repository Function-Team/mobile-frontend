import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/services/whatsapp_contact_service.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';

/// Reusable Contact Host Widget
/// in used in Venue Detail and Booking Detail pages
class ContactHostWidget extends StatelessWidget {
  final VenueModel? venue;
  final BookingModel? booking;
  final ContactHostStyle style;
  final String? customText;

  const ContactHostWidget({
    super.key,
    this.venue,
    this.booking,
    this.style = ContactHostStyle.button,
    this.customText,
  }) : assert(venue != null || booking != null,
            'Either venue or booking must be provided');

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ContactHostStyle.button:
        return _buildContactButton(context);
      case ContactHostStyle.card:
        return _buildContactCard(context);
      case ContactHostStyle.floating:
        return _buildFloatingButton(context);
      case ContactHostStyle.listTile:
        return _buildListTile(context);
    }
  }

  /// contact button - for venue detail
  Widget _buildContactButton(BuildContext context) {
    final theme = Theme.of(context);
    final isBookingContext = booking != null;

    return ElevatedButton.icon(
      onPressed: _handleContactHost,
      icon: Icon(
        isBookingContext ? Icons.help_outline : Icons.chat_bubble_outline,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        customText ??
            (isBookingContext
                ? 'Need Help?'
                : LocalizationHelper.tr(LocaleKeys.venue_contact)),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  /// Contact card - for booking detail
  Widget _buildContactCard(BuildContext context) {
    final theme = Theme.of(context);
    final hostName = _getHostName();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Host avatar
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            radius: 24,
            child: Text(
              hostName[0].toUpperCase(),
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Host info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  booking != null
                      ? 'Need help with your booking?'
                      : 'Have questions about this venue?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (booking != null) ...[
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
                      'Booking #${booking!.id}',
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

          // Contact button
          ElevatedButton.icon(
            onPressed: _handleContactHost,
            label: Text(LocalizationHelper.tr('buttons.contact')),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Floating action button
  Widget _buildFloatingButton(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: _handleContactHost,
      backgroundColor: theme.primaryColor,
      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      label: const Text(
        'Contact Host',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// List tile style
  Widget _buildListTile(BuildContext context) {
    final theme = Theme.of(context);
    final hostName = _getHostName();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.primaryColor,
        child: Icon(
          Icons.person,
          color: theme.primaryColor,
        ),
      ),
      title: Text(hostName),
      subtitle: Text(LocalizationHelper.tr('labels.tapToContactWhatsApp')),
      trailing: const Icon(Icons.chat_bubble_outline),
      onTap: _handleContactHost,
    );
  }

  /// Handle contact action
  void _handleContactHost() {
    if (venue != null) {
      WhatsAppContactService.contactHostFromVenue(venue: venue!);
    } else if (booking != null) {
      WhatsAppContactService.contactHostFromBooking(booking: booking!);
    }
  }

  /// Get host name from venue or booking
  String _getHostName() {
    if (venue?.host?.displayName != null) {
      return venue!.host!.displayName;
    } else if (booking?.place?.host?.displayName != null) {
      return booking!.place!.host!.displayName;
    }
    return 'Host';
  }

  /// Get venue name from venue or booking
  String _getVenueName() {
    if (venue?.name != null) {
      return venue!.name!;
    } else if (booking?.place?.name != null) {
      return booking!.place!.name!;
    }
    return 'Venue';
  }
}

/// Contact host widget styles
enum ContactHostStyle {
  button,
  card,
  floating,
  listTile,
}
