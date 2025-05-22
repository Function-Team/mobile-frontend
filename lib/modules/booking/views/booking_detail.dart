import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/booking/controllers/booking_detail_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingDetailPage extends GetView<BookingDetailController> {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        if (controller.booking.value == null) {
          return _buildNotFoundState();
        }

        return _buildBookingDetail(context);
      }),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Booking Details'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: controller.shareBooking,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                controller.refreshBookingDetail();
                break;
              case 'download':
                controller.downloadBookingReceipt();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Download Receipt'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading booking details...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshBookingDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Booking not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This booking may have been cancelled or does not exist.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetail(BuildContext context) {
    final booking = controller.booking.value!;

    return RefreshIndicator(
      onRefresh: controller.refreshBookingDetail,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, booking),
            const SizedBox(height: 16),
            _buildVenueCard(context, booking),
            const SizedBox(height: 16),
            _buildBookingDetailsCard(context, booking),
            const SizedBox(height: 16),
            _buildPricingCard(context, booking),
            const SizedBox(height: 16),
            _buildBookingInfoCard(context, booking),
            const SizedBox(height: 100), // Space for bottom actions
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, BookingModel booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking #${booking.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${_formatRelativeTime(booking.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.statusDisplayName,
                    style: TextStyle(
                      color: booking.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (!controller.isPastBooking)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.timeUntilBooking,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, BookingModel booking) {
    final venue = booking.place;
    if (venue == null) return const SizedBox.shrink();

    return Card(
      child: InkWell(
        onTap: controller.viewVenueDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageWithLoader(
                  imageUrl: venue.firstPictureUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name ?? 'Unknown Venue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            venue.address ?? 'Address not available',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (venue.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${venue.rating!.toStringAsFixed(1)} (${venue.ratingCount ?? 0} reviews)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context, BookingModel booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Date',
              value: booking.formattedDate,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Time',
              value: booking.formattedTimeRange,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              icon: Icons.schedule,
              label: 'Duration',
              value: controller.bookingSummary['duration_text'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              icon: Icons.people,
              label: 'Capacity',
              value: '${booking.place?.maxCapacity ?? 'N/A'} people',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, BookingModel booking) {
    final summary = controller.bookingSummary;
    if (summary.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow(
                'Base Price (${summary['hours']} hours)', summary['subtotal']),
            _buildPriceRow('Service Fee', summary['service_fee']),
            _buildPriceRow('Tax (10%)', summary['tax']),
            const Divider(height: 24),
            _buildPriceRow(
              'Total Amount',
              summary['total'],
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard(BuildContext context, BookingModel booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (booking.place?.rules != null &&
                booking.place!.rules!.isNotEmpty)
              _buildInfoSection(
                'Venue Rules',
                booking.place!.rules!,
                Icons.rule,
              ),
            const SizedBox(height: 12),
            _buildInfoSection(
              'Cancellation Policy',
              'Free cancellation up to 24 hours before the booking time. Late cancellations may incur charges.',
              Icons.policy,
            ),
            const SizedBox(height: 12),
            _buildInfoSection(
              'Contact Information',
              'For any questions or special requests, please contact the venue owner.',
              Icons.contact_support,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, dynamic amount, {bool isTotal = false}) {
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
            'IDR ${NumberFormat("#,##0", "id_ID").format(amount)}',
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

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Obx(() {
      final booking = controller.booking.value;
      if (booking == null) return const SizedBox.shrink();

      final actions = <Widget>[];

      // Contact venue owner
      actions.add(
        Expanded(
          child: OutlineButton(
            text: 'Contact Host',
            onPressed: () {},
            //controller.contactVenueOwner,
            height: 48,
          ),
        ),
      );

      // Add spacing between buttons
      if (actions.isNotEmpty) actions.add(const SizedBox(width: 12));

      // Action buttons based on booking status

      actions.add(
        Expanded(
          child: OutlineButton(
            text: controller.isCancelling.value
                ? 'Cancelling...'
                : 'Cancel Booking',
            onPressed: controller.isCancelling.value
                ? () {}
                : controller.showCancelConfirmationDialog,
            textColor: Colors.red,
            outlineColor: Colors.red,
            height: 48,
          ),
        ),
      );
      // actions.add(
      //   Expanded(
      //     child: PrimaryButton(
      //         text: controller.isLoading.value ? 'Loading...' : 'Reschedule',
      //         onPressed: () {}),
      //   ),
      // );

      if (actions.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(children: actions),
        ),
      );
    });
  }

  String _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }
}
