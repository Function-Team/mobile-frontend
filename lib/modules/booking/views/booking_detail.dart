import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/booking/controllers/booking_detail_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/contact_host_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class BookingDetailPage extends GetView<BookingDetailController> {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final booking = controller.booking.value;
        if (booking == null) {
          return _buildErrorState();
        }

        return _buildBookingDetail(context, booking);
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocalizationHelper.tr(LocaleKeys.booking_bookingDetail))),
      body: Center(
        child: Text(LocalizationHelper.tr(LocaleKeys.booking_bookingNotFound)),
      ),
    );
  }

  Widget _buildBookingDetail(BuildContext context, BookingModel booking) {
    return Scaffold(
      appBar: _buildAppBar(context, booking),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context, booking),
            const SizedBox(height: 16),
            _buildBookingInfoSection(context, booking),
            const SizedBox(height: 16),
            _buildContactSection(context, booking),
            const SizedBox(height: 16),
            _buildPricingSection(context, booking),
            const SizedBox(height: 100),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, booking),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, BookingModel booking) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationHelper.tr(LocaleKeys.booking_bookingDetail),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ID: #${booking.id}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: _buildStatusChip(booking),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BookingModel booking) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    if (booking.isConfirmed && booking.isPaid) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      statusText = LocalizationHelper.tr(LocaleKeys.booking_status_completed);
    } else if (booking.isConfirmed && !booking.isPaid) {
      backgroundColor = Colors.orange;
      textColor = Colors.white;
      statusText = LocalizationHelper.tr(LocaleKeys.booking_status_confirmed);
    } else if (!booking.isConfirmed && booking.isPaid) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      statusText = LocalizationHelper.tr(LocaleKeys.booking_status_paid);
    } else if (booking.paymentStatus == 'cancelled') {
      backgroundColor = Colors.red;
      textColor = Colors.white;
      statusText = LocalizationHelper.tr(LocaleKeys.booking_status_cancelled);
    } else {
      backgroundColor = Colors.grey;
      textColor = Colors.white;
      statusText = LocalizationHelper.tr(LocaleKeys.booking_status_pending);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, BookingModel booking) {
    final venue = booking.place;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: venue?.firstPictureUrl != null
                  ? NetworkImageWithLoader(
                      imageUrl: venue!.firstPictureUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Venue Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue?.name ??
                                booking.placeName ??
                                LocalizationHelper.tr(LocaleKeys.location_unknownVenue),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  venue?.address ??
                                      LocalizationHelper.tr(
                                          'location.addressNotAvailable'),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.viewVenueDetails,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(LocalizationHelper.tr('buttons.view')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoSection(BuildContext context, BookingModel booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationHelper.tr(LocaleKeys.booking_bookingInformation),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoTile(
            icon: Icons.calendar_today,
            label: LocalizationHelper.tr(LocaleKeys.common_date),
            value: _formatDate(booking.startDateTime),
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.access_time,
            label: LocalizationHelper.tr(LocaleKeys.common_time),
            value: _formatTimeRange(booking),
            iconColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.timelapse,
            label: LocalizationHelper.tr(LocaleKeys.booking_duration),
            value: _calculateDuration(booking),
            iconColor: Colors.orange,
          ),
          if (booking.createdAt != null) ...[
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.schedule,
              label: LocalizationHelper.tr(LocaleKeys.booking_bookedOn),
              value:
                  DateFormat('MMM dd, yyyy - HH:mm').format(booking.createdAt!),
              iconColor: Colors.purple,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, BookingModel booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ContactHostWidget(
        booking: booking,
        style: ContactHostStyle.button,
        customText: LocalizationHelper.tr('labels.needHelpContactHost'),
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, BookingModel booking) {
    final amount = booking.amount ?? 0.0;
    final venue = booking.place;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationHelper.tr(LocaleKeys.booking_paymentSummary),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Only show price breakdown if amount > 0
          if (amount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationHelper.tr(LocaleKeys.booking_duration),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _calculateDuration(booking),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (venue?.price != null && venue!.price! > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocalizationHelper.tr(LocaleKeys.booking_ratePerHour),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(venue.price)}/hour',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationHelper.tr(LocaleKeys.booking_totalAmount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                amount > 0
                    ? 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}'
                    : LocalizationHelper.tr(LocaleKeys.common_free),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: amount > 0 ? Colors.green[600] : Colors.blue[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, BookingModel booking) {
    final canCancel = !booking.isConfirmed &&
        booking.paymentStatus != 'cancelled' &&
        booking.paymentStatus != 'success';

    final needsPayment = booking.isConfirmed &&
        !booking.isPaid &&
        booking.paymentStatus == 'pending' &&
        booking.payment?.expiresAt != null &&
        DateTime.now().isBefore(booking.payment!.expiresAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (canCancel) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_cancelBooking),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (needsPayment) const SizedBox(width: 12),
            ],
            if (needsPayment) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _proceedToPayment(booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_payNow),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime dateTime) {
    return DateFormat('EEEE, MMM dd, yyyy').format(dateTime);
  }

  String _formatTimeRange(BookingModel booking) {
    final startTime = DateFormat('HH:mm').format(booking.startDateTime);
    final endTime = DateFormat('HH:mm').format(booking.endDateTime);
    return '$startTime - $endTime';
  }

  String _calculateDuration(BookingModel booking) {
    final duration = booking.endDateTime.difference(booking.startDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationHelper.tr(LocaleKeys.booking_cancelBooking)),
        content: Text(LocalizationHelper.tr(
            LocaleKeys.booking_cancelConfirmationMessage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationHelper.tr(LocaleKeys.booking_keepBooking)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.showCancelConfirmationDialog();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(LocalizationHelper.tr(LocaleKeys.booking_yesCancel)),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment(BookingModel booking) {
    // Navigate to payment page
    Get.toNamed('/payment', arguments: booking);
  }
}
