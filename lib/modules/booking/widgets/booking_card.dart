import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:get/get.dart';
import '../controllers/booking_card_controller.dart';
import 'package:function_mobile/common/routes/routes.dart';

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.expired:
        return Colors.red;
    }
  }

  // Metode untuk mengkonversi string ke enum
  static final Map<String, BookingStatus> _statusMap = {
    'confirmed': BookingStatus.confirmed,
    'pending': BookingStatus.pending,
    'cancelled': BookingStatus.cancelled,
    'expired': BookingStatus.expired,
  };

  static BookingStatus fromString(String status) =>
      _statusMap[status.toLowerCase()] ?? BookingStatus.pending;
}

class BookingCard extends StatelessWidget {
  final BookingModel bookingModel;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onViewVenue;
  final BookingCardController? _controller;

  BookingCard({
    super.key,
    required this.bookingModel,
    required this.onTap,
    this.onCancel,
    this.onViewVenue,
  }) : _controller = null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(MyRoutes.bookingDetail,
            arguments: bookingModel.id.toString());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.tertiary, width: 0.25),
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with booking ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${bookingModel.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),

              // Venue info
              _buildVenueInfo(context),
              const SizedBox(height: 12),

              // Booking details
              _buildBookingDetails(context),
              const SizedBox(height: 12),

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bookingModel.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bookingModel.statusDisplayName,
        style: TextStyle(
          color: bookingModel.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVenueInfo(BuildContext context) {
    return Row(
      children: [
        // Venue image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: bookingModel.place?.firstPictureUrl != null
                ? Image.network(
                    bookingModel.place!.firstPictureUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.location_city,
                        size: 30,
                        color: Colors.grey[400],
                      );
                    },
                  )
                : Icon(
                    Icons.location_city,
                    size: 30,
                    color: Colors.grey[400],
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // Venue details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookingModel.place?.name ?? 'Unknown Venue',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (bookingModel.place?.city != null)
                Text(
                  bookingModel.place!.city!.name ?? 'Unknown City',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 4),
              if (bookingModel.place?.price != null)
                Text(
                  'Rp ${_formatPrice(bookingModel.place!.price!)} / day',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                bookingModel.formattedDate,
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                bookingModel.formattedTimeRange,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (bookingModel.status == BookingStatus.pending) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Awaiting admin confirmation',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (bookingModel.status) {
      case BookingStatus.confirmed:
        return _buildConfirmedActions(context);
      case BookingStatus.pending:
        return _buildPendingActions(context);
      case BookingStatus.cancelled:
      case BookingStatus.expired:
        return _buildInactiveActions(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConfirmedActions(BuildContext context) {
    // Check if payment is needed (you can add payment status logic here)
    final bool needsPayment = bookingModel.payment == null;

    return Row(
      children: [
        if (needsPayment) ...[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _proceedToPayment(context),
              icon: const Icon(Icons.payment, size: 16),
              label: const Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _contactVenue(context),
            icon: const Icon(Icons.chat, size: 16),
            label: const Text('Contact'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewVenue ?? () => _viewVenue(context),
            icon: const Icon(Icons.location_on, size: 16),
            label: const Text('View'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancel ?? () => _cancelBooking(context),
            icon: const Icon(Icons.cancel, size: 16),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewVenue ?? () => _viewVenue(context),
            icon: const Icon(Icons.location_on, size: 16),
            label: const Text('View Venue'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewVenue ?? () => _viewVenue(context),
            icon: const Icon(Icons.location_on, size: 16),
            label: const Text('View Venue'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Action methods
  void _proceedToPayment(BuildContext context) {
    Get.toNamed('/payment', arguments: bookingModel);
  }

  void _contactVenue(BuildContext context) {
    // Implement contact venue functionality
    Get.snackbar(
      'Contact Venue',
      'Contacting venue owner...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _viewVenue(BuildContext context) {
    if (bookingModel.place?.id != null) {
      Get.toNamed('/venue-detail', arguments: {
        'venueId': bookingModel.place!.id,
      });
    }
  }

  void _cancelBooking(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel this booking for ${bookingModel.place?.name ?? "this venue"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (onCancel != null) {
                onCancel!();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
