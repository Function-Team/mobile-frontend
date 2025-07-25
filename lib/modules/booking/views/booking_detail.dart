import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/controllers/booking_detail_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingDetailPage extends GetView<BookingDetailController> {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          'Booking Details',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshBookingDetail,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading booking',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.fetchBookingDetail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final booking = controller.booking.value;
        if (booking == null) {
          return const Center(child: Text('No booking data available'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshBookingDetail,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusHeader(context, booking),
                _buildVenueInfo(context, booking),
                _buildBookingInfo(context, booking),
                _buildPricingSummary(context, booking),
                if (!controller.isBookingCompleted)
                  _buildActionButtons(context, booking),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(BuildContext context, BookingModel booking) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (controller.isBookingCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed - Paid';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = booking.statusColor;
      statusText = booking.statusDisplayName;
      statusIcon = booking.status == BookingStatus.confirmed
          ? Icons.check_circle_outline
          : booking.status == BookingStatus.pending
              ? Icons.schedule
              : Icons.cancel;
    }

    // Check if needs payment
    final bool needsPayment =
        booking.isConfirmed && !controller.isBookingCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      color: statusColor.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Booking ID: #${booking.id}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          if (needsPayment) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Required',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            controller.timeUntilBooking,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueInfo(BuildContext context, BookingModel booking) {
    final venue = booking.place;
    if (venue == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: NetworkImageWithLoader(
              imageUrl: venue.firstPictureUrl ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name ?? 'Unknown Venue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address ?? 'No address',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${venue.rating?.toStringAsFixed(1) ?? '0.0'} (${venue.ratingCount ?? 0} reviews)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.viewVenueDetails,
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Venue Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo(BuildContext context, BookingModel booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Date', booking.formattedDate),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Time', booking.formattedTimeRange),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.timer, 'Duration',
              controller.bookingSummary['duration_text'] ?? ''),
          if (booking.user != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Guest Name', booking.user!.username),
          ],
          if (controller.isBookingCompleted && booking.payment != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.payment, 'Payment Status',
                'Paid on ${DateFormat('MMM dd, yyyy').format(booking.payment!.createdAt)}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSummary(BuildContext context, BookingModel booking) {
    final summary = controller.bookingSummary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (controller.isBookingCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'PAID',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Base Price',
              'IDR ${NumberFormat("#,##0", "id_ID").format(summary['base_price'] ?? 0)}'),
          _buildPriceRow('Duration',
              '${summary['hours']?.toStringAsFixed(1) ?? '0'} hours'),
          _buildPriceRow('Subtotal',
              'IDR ${NumberFormat("#,##0", "id_ID").format(summary['subtotal'] ?? 0)}'),
          _buildPriceRow('Tax (10%)',
              'IDR ${NumberFormat("#,##0", "id_ID").format(summary['tax'] ?? 0)}'),
          _buildPriceRow('Service Fee',
              'IDR ${NumberFormat("#,##0", "id_ID").format(summary['service_fee'] ?? 0)}'),
          const Divider(height: 24),
          _buildPriceRow(
            'Total',
            'IDR ${NumberFormat("#,##0", "id_ID").format(summary['total'] ?? 0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(Get.context!).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BookingModel booking) {
    final bool needsPayment =
        booking.isConfirmed && !controller.isBookingCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pay Now button for confirmed but unpaid bookings
          if (needsPayment) ...[
            PrimaryButton(
              text: 'Pay Now',
              onPressed: () async {
                // Use BookingController for payment
                if (!Get.isRegistered<BookingController>()) {
                  Get.put(BookingController());
                }
                final bookingController = Get.find<BookingController>();
                await bookingController.createPaymentForBooking(booking);

                // Refresh booking detail
                await Future.delayed(const Duration(seconds: 2));
                controller.refreshBookingDetail();
              },
              isLoading: true,
              width: double.infinity,
              leftIcon: Icons.payment,
            ),
            const SizedBox(height: 12),
          ],

          // Other action buttons
          Row(
            children: [
              if (controller.canCancel) ...[
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel Booking',
                    onPressed: controller.showCancelConfirmationDialog,
                    textColor: Colors.white,
                  ),
                ),
              ],
              if (controller.isBookingCompleted) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.shareBooking,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
