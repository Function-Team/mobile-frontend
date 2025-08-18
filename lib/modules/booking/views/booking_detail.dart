import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/booking/controllers/booking_detail_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/contact_host_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshBookingDetail();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeaderSection(context, booking),
              const SizedBox(height: 16),
              _buildStatusSection(context, booking),
              const SizedBox(height: 16),
              _buildBookingInfoSection(context, booking),
              const SizedBox(height: 16),
              _buildGuestInfoSection(context, booking),
              const SizedBox(height: 16),
              _buildContactSection(context, booking),
              const SizedBox(height: 16),
              _buildPricingSection(context, booking),
              const SizedBox(height: 16),
              // Tampilkan bagian review jika sudah ada review
              if (booking.reviews != null && booking.reviews!.isNotEmpty)
                _buildReviewSection(context, booking),
              const SizedBox(height: 100),
            ],
          ),
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
    // Menggunakan getter dari BookingModel untuk konsistensi
    final backgroundColor = booking.statusColor;
    final statusText = booking.statusDisplayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
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
                                LocalizationHelper.tr(
                                    LocaleKeys.location_unknownVenue),
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
              label: 'Start Date & Time',
              value: _formatFullDateTime(booking.startDateTime),
              iconColor: Colors.blue,
              isMultiline: true),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.event,
            label: 'End Date & Time',
            value: _formatFullDateTime(booking.endDateTime),
            iconColor: Colors.red,
            isMultiline: true,
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
          if (booking.amount != null && booking.amount! > 0) ...[
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.attach_money,
              label: 'Total Amount',
              value:
                  'Rp ${NumberFormat('#,###', 'id_ID').format(booking.amount!)}',
              iconColor: Colors.green[600]!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestInfoSection(BuildContext context, BookingModel booking) {
    // Only show guest info section if there's guest information available
    if (booking.guestName == null &&
        booking.guestEmail == null &&
        booking.guestPhone == null &&
        booking.guestCount == null &&
        booking.specialRequest == null) {
      return const SizedBox.shrink();
    }

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
          const Text(
            'Guest Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (booking.guestName != null && booking.guestName!.isNotEmpty) ...[
            _buildInfoTile(
              icon: Icons.person,
              label: 'Guest Name',
              value: booking.guestName!,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 16),
          ],
          if (booking.guestEmail != null && booking.guestEmail!.isNotEmpty) ...[
            _buildInfoTile(
              icon: Icons.email,
              label: 'Email',
              value: booking.guestEmail!,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
          ],
          if (booking.guestPhone != null && booking.guestPhone!.isNotEmpty) ...[
            _buildInfoTile(
              icon: Icons.phone,
              label: 'Phone',
              value: booking.guestPhone!,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 16),
          ],
          if (booking.guestCount != null) ...[
            _buildInfoTile(
              icon: Icons.group,
              label: 'Guest Count',
              value:
                  '${booking.guestCount} ${booking.guestCount == 1 ? 'guest' : 'guests'}',
              iconColor: Colors.purple,
            ),
            const SizedBox(height: 16),
          ],
          if (booking.specialRequest != null &&
              booking.specialRequest!.isNotEmpty) ...[
            _buildInfoTile(
              icon: Icons.note,
              label: 'Special Request',
              value: booking.specialRequest!,
              iconColor: Colors.red,
              isMultiline: true,
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

  Widget _buildStatusSection(BuildContext context, BookingModel booking) {
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
          const Text(
            'Booking Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: booking.statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  booking
                      .statusDisplayName, // Menggunakan statusDisplayName untuk konsistensi dengan app bar dan booking list
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.timeUntilBooking,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (booking.status == BookingStatus.expired) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_filled, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Expired',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'This booking has expired and is no longer valid',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (booking.isPaid) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Completed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (booking.payment?.createdAt != null)
                          Text(
                            'Paid on ${DateFormat('dd MMM yyyy, HH:mm').format(booking.payment!.createdAt)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (booking.isConfirmed &&
              !booking.isPaid &&
              booking.status != BookingStatus.expired) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Your booking is confirmed but payment is still pending',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Text(
                LocalizationHelper.tr(LocaleKeys.booking_paymentSummary),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Only show price breakdown if amount > 0
          if (amount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      LocalizationHelper.tr(LocaleKeys.booking_duration),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  _calculateDuration(booking),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (venue?.price != null && venue!.price! > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        LocalizationHelper.tr(LocaleKeys.booking_ratePerHour),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(venue.price)}/hour',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),
          ],

          // Total amount (highlighted box)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: amount > 0 ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationHelper.tr(LocaleKeys.booking_totalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  amount > 0
                      ? 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}'
                      : LocalizationHelper.tr(LocaleKeys.common_free),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: amount > 0 ? Colors.green[700] : Colors.blue[700],
                  ),
                ),
              ],
            ),
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
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                maxLines: isMultiline ? null : 1,
                overflow:
                    isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, BookingModel booking) {
    // Gunakan controller.canCancel untuk konsistensi dengan logika di controller
    final canCancel = controller.canCancel;

    // Gunakan logika yang lebih jelas untuk menentukan apakah perlu pembayaran
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
                child: PrimaryButton(
                  text: 'Cancel Booking',
                  onPressed: () => _showCancelDialog(context),
                  backgroundColor: Colors.white,
                  isLoading: false,
                  height: 50,
                ),
              ),
              if (needsPayment) const SizedBox(width: 12),
            ],
            if (needsPayment) ...[
              Expanded(
                child: PrimaryButton(
                  text: 'Pay Now',
                  onPressed: () => controller.proceedToPayment(booking),
                  backgroundColor: Colors.green,
                  isLoading: false,
                  height: 50,
                ),
              ),
            ],
            if (controller.isEligibleForReview.value) ...[
              Expanded(
                child: PrimaryButton(
                  text: controller.hasBeenReviewed
                      ? 'Edit Review'
                      : 'Write a Review',
                  onPressed: () => controller.navigateToReviewForm(booking),
                  backgroundColor: Colors.blue,
                  isLoading: false,
                  height: 50,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM dd, yyyy - HH:mm').format(dateTime);
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

  Widget _buildReviewSection(BuildContext context, BookingModel booking) {
    // Pastikan booking memiliki review sebelum mengakses
    if (booking.reviews == null || booking.reviews!.isEmpty) {
      return const SizedBox
          .shrink(); // Jangan tampilkan apa-apa jika tidak ada review
    }

    // Ambil review pertama dari booking
    final review = booking.reviews!.first;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.navigateToReviewForm(booking),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  foregroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRatingStars(review.rating),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMM yyyy').format(review.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int? rating) {
    // Pastikan rating valid (1-5) atau default ke 0 jika null/invalid
    final validRating =
        (rating != null && rating >= 1 && rating <= 5) ? rating : 0;

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < validRating ? Icons.star : Icons.star_border,
          color: index < validRating ? Colors.amber : Colors.grey,
          size: 18,
        );
      }),
    );
  }
}
