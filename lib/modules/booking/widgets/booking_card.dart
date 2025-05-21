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
      case BookingStatus.other:
        return 'Other';
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
      case BookingStatus.other:
        return Colors.blue;
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
      _statusMap[status.toLowerCase()] ?? BookingStatus.other;
}

class BookingCard extends StatelessWidget {
  final BookingModel bookingModel;
  final VoidCallback onTap;
  final BookingCardController? _controller;

  BookingCard({
    super.key,
    required this.bookingModel,
    required this.onTap,
  }) : _controller = null; // Inisialisasi controller di sini

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
        margin: EdgeInsets.symmetric(vertical: 6),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                      children: [
                        const TextSpan(
                          text: 'ID: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: bookingModel.id.toString(),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                  children: [
                    const TextSpan(
                      text: 'Venue: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: bookingModel.venue.name,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                          '${bookingModel.dateRange.start.day} - ${bookingModel.dateRange.end.day}',
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(bookingModel.dateRange.start.toString(),
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Price: Rp. ${bookingModel.venue.price}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // Use the stored controller reference instead of finding it again
    final BookingCardController? timerController = _controller;

    // Buat widget Row yang akan berisi timer dan status badge
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer widget - gunakan Obx terpisah
        if (timerController != null)
          Obx(() {
            final status = timerController.status.value;
            final remaining = timerController.remainingTime.value;

            // Hanya tampilkan timer jika status masih pending dan remaining tidak null
            if (status != BookingStatus.pending || remaining == null) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    timerController.formatDuration(remaining),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),

        // Extract status badge to a separate method for better readability
        _buildStatusIndicator(timerController),
      ],
    );
  }

  // New method to extract status badge logic
  Widget _buildStatusIndicator(BookingCardController? timerController) {
    if (timerController != null) {
      return Obx(() {
        final status = timerController.status.value;
        final Color statusColor = status.color;
        final String statusText = status.displayName;

        return _buildStatusContainer(statusColor, statusText);
      });
    } else {
      return _buildStatusContainer(
          bookingModel.status.color, bookingModel.status.displayName);
    }
  }

  // Extract common container building logic
  Widget _buildStatusContainer(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
