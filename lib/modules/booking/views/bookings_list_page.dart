import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/widgets/booking_card.dart';
import 'package:get/get.dart';

class BookingListPage extends GetView<BookingListController> {
  const BookingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildBookingList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'My Bookings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.refreshBookings,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Obx(() => Row(
              children: List.generate(
                controller.tabTitles.length,
                (index) => _buildTabButton(index),
              ),
            )),
      ),
    );
  }

  Widget _buildTabButton(int index) {
    // ✅ FIXED: Single Obx per button, clean access
    final isSelected = controller.currentTabIndex.value == index;
    final count = controller.getTabCount(index);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? Colors.blue : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.changeTab(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.tabTitles[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return _buildErrorState();
      }

      if (controller.filteredBookings.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshBookings,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = controller.filteredBookings[index];
            return BookingCard(
              bookingModel: booking,
              onTap: () => _navigateToBookingDetail(booking),
              onCancel: booking.isInCancelledSection
                  ? null
                  : () => controller.showCancelConfirmationDialog(booking),
              onViewVenue: () => _navigateToVenueDetail(booking),
              onPayNow: (booking.needsPayment && !booking.isInCancelledSection)
                  ? () => controller.createPaymentForBooking(booking)
                  : null,
            );
          },
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load bookings',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshBookings,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String message;
    IconData icon;

    switch (controller.currentTabIndex.value) {
      case 0:
        title = 'No Bookings Yet';
        message = 'Start exploring venues and make your first booking!';
        icon = Icons.calendar_today;
        break;
      case 1:
        title = 'No Pending Bookings';
        message = 'All your bookings have been processed.';
        icon = Icons.pending;
        break;
      case 2:
        title = 'No Confirmed Bookings';
        message = 'No bookings are waiting for payment.';
        icon = Icons.check_circle;
        break;
      case 3:
        title = 'No Completed Bookings';
        message = 'Complete a booking to see it here.';
        icon = Icons.done_all;
        break;
      case 4:
        title = 'No Cancelled Bookings';
        message = 'You haven\'t cancelled any bookings yet.';
        icon = Icons.cancel;
        break;
      default:
        title = 'No Bookings';
        message = 'No bookings found.';
        icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (controller.currentTabIndex.value == 0) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: const Text('Explore Venues'),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToBookingDetail(BookingModel booking) {
    Get.toNamed(MyRoutes.bookingDetail, arguments: booking.id);
  }

  void _navigateToVenueDetail(BookingModel booking) {
    if (booking.place?.id != null) {
      Get.toNamed(MyRoutes.venueDetail, arguments: {
        'venueId': booking.place!.id,
      });
    }
  }
}
