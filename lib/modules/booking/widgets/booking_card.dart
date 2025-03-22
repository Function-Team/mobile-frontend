import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_card_controller.dart';

enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  expired,
  other,
}

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
  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      default:
        return BookingStatus.other;
    }
  }
}

class BookingCard extends StatelessWidget {
  final String venueName;
  final int bookingID;
  final String bookingDate;
  final String bookingTime;
  final BookingStatus bookingStatus;
  final int price;
  final String priceType;
  final Duration? timeRemaining;

  BookingCard({
    super.key,
    required this.venueName,
    required this.bookingID,
    required this.bookingDate,
    required this.bookingTime,
    required this.bookingStatus,
    required this.price,
    required this.priceType,
    this.timeRemaining,
  }) {
    // Inisialisasi controller jika ada timeRemaining
    if (timeRemaining != null && bookingStatus == BookingStatus.pending) {
      final controller = Get.put(
          BookingCardController(bookingId: bookingID.toString()),
          tag: 'booking_$bookingID');
      controller.startTimer(timeRemaining!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
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
                          text: bookingID.toString(),
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
                      text: venueName,
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
                      Text(bookingDate,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(bookingTime,
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
                  'Price: $priceType $price',
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
    // Dapatkan controller jika status pending dan ada timeRemaining
    final BookingCardController? timerController =
        (timeRemaining != null && bookingStatus == BookingStatus.pending)
            ? Get.find<BookingCardController>(tag: 'booking_$bookingID')
            : null;

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

        // Status badge - gunakan Obx terpisah
        timerController != null
            ? Obx(() {
                final status = timerController.status.value;
                final Color statusColor = status.color;
                final String statusText = status.displayName;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              })
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: bookingStatus.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bookingStatus.color, width: 1),
                ),
                child: Text(
                  bookingStatus.displayName,
                  style: TextStyle(
                    color: bookingStatus.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
      ],
    );
  }
}
