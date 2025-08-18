import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
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
            LocalizationHelper.tr(LocaleKeys.appBarTitles_booking),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Summary Card
                  _buildVenueSummaryCard(context),
                  // Booking Form
                  BookingForm(
                    controller: controller,
                    venue: venue,
                  ),
                  SizedBox(height: 100), // Extra space for bottom bar
                ],
              ),
            ),
            // Bottom Bar
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
      CustomSnackbar.show(
        context: Get.context!, 
        message: LocalizationHelper.tr(LocaleKeys.bookingPage_refreshing), 
        type: SnackbarType.info,
        autoClear: true,
        enableDebounce: false, // Show loading immediately
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
      CustomSnackbar.show(
        context: Get.context!, 
        message: LocalizationHelper.tr(LocaleKeys.bookingPage_updated), 
        type: SnackbarType.success,
        autoClear: true,
        enableDebounce: false, // Show success immediately
      );

    } catch (e) {
      // Error feedback
      CustomSnackbar.show(
        context: Get.context!, 
        message: LocalizationHelper.tr(LocaleKeys.bookingPage_refreshFailed), 
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false, // Show errors immediately
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
                    venue.name ?? LocalizationHelper.tr(LocaleKeys.bookingPage_venue),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
                          venue.city?.name ?? LocalizationHelper.tr(LocaleKeys.venue_location),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
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
                        LocalizationHelper.tr(LocaleKeys.bookingPage_maxGuests).replaceAll('{count}', '${venue.maxCapacity}'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
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
                        venue.category?.name ?? LocalizationHelper.tr(LocaleKeys.bookingPage_category),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
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
          LocalizationHelper.tr(LocaleKeys.bookingPage_selectDateTimePrompt),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
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
          LocalizationHelper.tr(LocaleKeys.bookingPage_minimumDuration),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
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
              LocalizationHelper.tr(LocaleKeys.bookingPage_totalHours).replaceAll('{hours}', totalHours.toStringAsFixed(1)),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            Text(
              controller.formatDuration(duration),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        Text(
          'Rp ${NumberFormat('#,###').format(totalAmount)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}