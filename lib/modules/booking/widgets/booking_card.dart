import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/booking/constants/status_constants.dart';
import 'package:function_mobile/modules/booking/controllers/booking_card_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class BookingCard extends StatelessWidget {
  final BookingModel bookingModel;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onViewVenue;
  final VoidCallback? onPayNow;

  const BookingCard({
    super.key,
    required this.bookingModel,
    required this.onTap,
    this.onCancel,
    this.onViewVenue,
    this.onPayNow,
  });

  bool get isCompleted => bookingModel.isConfirmed && bookingModel.isPaid;

  String get venueName {
    if (bookingModel.place?.name?.isNotEmpty ?? false) {
      return bookingModel.place!.name!;
    }
    if (bookingModel.placeName?.isNotEmpty ?? false) {
      return bookingModel.placeName!;
    }
    return LocalizationHelper.tr(LocaleKeys.location_venueNotAvailable);
  }

  String get venueAddress {
    if (bookingModel.place?.address?.isNotEmpty ?? false) {
      return bookingModel.place!.address!;
    }

    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final bookingDate = dateFormat.format(bookingModel.startDateTime);
    return 'Booking: $bookingDate';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatusBadge(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithLoader(
                      imageUrl: bookingModel.place?.firstPictureUrl ?? '',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venueName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venueAddress,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatBookingTime(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (bookingModel.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.history,
                                  size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bookingModel.createdAtDisplay,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_shouldShowPaymentTimer()) ...[
                          const SizedBox(height: 8),
                          _buildPaymentTimer(),
                        ],
                        if (bookingModel.isInCancelledSection &&
                            bookingModel.cancelReason?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 12, color: Colors.red[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    bookingModel.cancelReason!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildPriceAndActions(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    // Menggunakan getter dari BookingModel untuk konsistensi
    final statusColor = bookingModel.statusColor;
    final statusText = bookingModel.statusDisplayName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriceAndActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (bookingModel.amount != null && bookingModel.amount! > 0)
          Text(
            'Rp${NumberFormat('#,###', 'id_ID').format(bookingModel.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: bookingModel.isInCancelledSection
                  ? Colors.grey[600]
                  : Colors.black87,
              decoration: bookingModel.isInCancelledSection
                  ? TextDecoration.lineThrough
                  : null,
            ),
          )
        else
          Text(
            LocalizationHelper.tr(LocaleKeys.common_free),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: bookingModel.isInCancelledSection
                  ? Colors.grey[600]
                  : Colors.green,
              decoration: bookingModel.isInCancelledSection
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        Row(
          children: [
            if (bookingModel.isInCancelledSection) ...[
              if (_canRebook())
                ElevatedButton(
                  onPressed: onViewVenue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                      LocalizationHelper.tr(LocaleKeys.booking_bookAgain),
                      style: const TextStyle(fontSize: 12)),
                ),
            ] else ...[
              if (_shouldShowCancelButton() && onCancel != null)
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(LocalizationHelper.tr(LocaleKeys.booking_cancel),
                      style: const TextStyle(fontSize: 12)),
                ),
              if (_shouldShowCancelButton() && _shouldShowPayNowButton())
                const SizedBox(width: 8),
              if (_shouldShowPayNowButton() && onPayNow != null)
                ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(LocalizationHelper.tr(LocaleKeys.common_pay),
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatBookingTime() {
    final startFormat = DateFormat('dd MMM, HH:mm', 'id_ID');
    final endFormat = DateFormat('HH:mm', 'id_ID');

    final startStr = startFormat.format(bookingModel.startDateTime);
    final endStr = endFormat.format(bookingModel.endDateTime);

    return '$startStr - $endStr';
  }

  bool _shouldShowCancelButton() {
    return !bookingModel.isInCancelledSection &&
        !isCompleted &&
        !bookingModel.isConfirmed &&
        bookingModel.startDateTime.isAfter(DateTime.now());
  }

  bool _shouldShowPayNowButton() {
    return bookingModel.isConfirmed &&
        !bookingModel.isPaid &&
        !bookingModel.isInCancelledSection &&
        (bookingModel.paymentStatus == 'pending' ||
            bookingModel.paymentStatus == null);
  }

  bool _canRebook() {
    // Allow rebooking if the venue is still available
    return bookingModel.place != null;
  }

  Widget _buildPaymentTimer() {
    return GetBuilder<BookingCardController>(
      init: BookingCardController(),
      builder: (timerController) {
        // Check if timer should be stopped based on booking status
        timerController.checkAndStopTimerIfExpired(bookingModel.status);

        if (bookingModel.payment?.expiresAt != null &&
            bookingModel.status != BookingStatus.expired &&
            !bookingModel.isBookingCancelled) {
          timerController.initializeTimer(bookingModel.payment!.expiresAt);
        } else {
          // Stop timer if conditions are not met
          timerController.stopTimer();
        }

        return Obx(() {
          if (timerController.remainingTime.value == null)
            return const SizedBox.shrink();

          final remaining = timerController.remainingTime.value!;
          final isUrgent = remaining.inHours < 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isUrgent ? Colors.red.shade200 : Colors.orange.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: isUrgent ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pay within: ${timerController.formatDuration(remaining)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  bool _shouldShowPaymentTimer() {
    // UNIFIED LOGIC: Jangan tampilkan timer jika booking sudah expired
    // (baik karena payment expired maupun booking time expired)
    if (bookingModel.status == BookingStatus.expired) {
      return false;
    }

    // Jangan tampilkan timer jika booking sudah dibatalkan
    if (bookingModel.isBookingCancelled) {
      return false;
    }

    // Tampilkan timer hanya untuk booking yang dikonfirmasi tapi belum dibayar
    return bookingModel.isConfirmed &&
        !bookingModel.isPaid &&
        bookingModel.paymentStatus == 'pending' &&
        bookingModel.payment?.expiresAt != null;
  }
}
