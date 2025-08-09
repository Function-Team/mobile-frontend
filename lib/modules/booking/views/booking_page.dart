import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/widgets/booking_form.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatelessWidget {
  final BookingController controller = Get.put(BookingController());
  final VenueModel venue;

  BookingPage({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshPageData();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Book ${venue.name}',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.white),
          ),
          titleTextStyle: TextStyle(color: Colors.white),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Summary Card
                  _buildVenueSummaryCard(context),

                  // Price Information
                  _buildPriceInfoCard(context),

                  // Booking Form
                  BookingForm(
                    controller: controller,
                    venue: venue,
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshPageData() async {
    try {
      // Show loading feedback
      Get.snackbar(
        'Refreshing...',
        'Updating booking availability',
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
      );

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      await controller.loadCalendarAvailability(
          venue.id, startOfMonth, endOfMonth);

      // Refresh time slots if date is selected
      if (controller.selectedDate.value != null) {
        await controller.loadDetailedTimeSlots(
            venue.id, controller.selectedDate.value!);
      }

      // Success feedback
      Get.snackbar(
        'Updated',
        'Booking availability refreshed',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
      );
    } catch (e) {
      // Error feedback
      Get.snackbar(
        'Refresh Failed',
        'Could not update data. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
      );
    }
  }

  Widget _buildVenueSummaryCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: venue.firstPictureUrl != null
                        ? NetworkImageWithLoader(
                            imageUrl: venue.firstPictureUrl!,
                            fit: BoxFit.cover,
                          )
                        : _buildImagePlaceholder()),
              ),

              SizedBox(height: 16),

              // Venue Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name ?? 'Venue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.city?.name ?? 'Location',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Max: ${venue.maxCapacity} guests',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        venue.category?.name ?? 'Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey[600]),
    );
  }

  Widget _buildPriceInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Text(
                    'Pricing Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Base Price: Rp ${NumberFormat('#,###').format(venue.price ?? 0)} per hour',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                '• Minimum booking: 1 hour',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Maximum booking: 7 days',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Time slots: 30-minute increments',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Payment after host confirmation',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Obx(() => _buildTotalPriceBar(context)),
        ),
      ),
    );
  }

  Widget _buildTotalPriceBar(BuildContext context) {
    if (controller.selectedDate.value == null ||
        controller.startTime.value == null ||
        controller.endTime.value == null) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          'Please select date and time to see total price',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final startDate = controller.selectedDate.value!;
    final endDate = controller.selectedDate.value!;
    final startTime = controller.startTime.value!;
    final endTime = controller.endTime.value!;

    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    final duration = end.difference(start);
    final totalHours = duration.inMinutes / 60.0;
    final totalAmount = (venue.price ?? 0) * totalHours;

    if (duration < Duration(hours: 1)) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          'Minimum booking duration is 1 hour',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (duration > Duration(days: 7)) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          'Maximum booking duration is 7 days',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total (${totalHours.toStringAsFixed(1)} hours)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              controller.formatDuration(duration),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          'Rp ${NumberFormat('#,###').format(totalAmount)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}