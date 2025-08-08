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
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Booking List',
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Colors.white),
        ),
        actions: [Icon(Icons.refresh)],
      ),
      body: Column(
        children: [
          _buildSortIndicator(),
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
        Obx(() => PopupMenuButton<String>(
              icon: Stack(
                children: [
                  const Icon(Icons.sort),
                  // Active indicator dot
                  if (controller.selectedSort.value != 'booking_id_desc')
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onSelected: (String value) {
                controller.setSortOption(value);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'booking_id_desc',
                  child: Row(
                    children: [
                      Icon(Icons.tag,
                          size: 16,
                          color:
                              controller.selectedSort.value == 'booking_id_desc'
                                  ? Colors.blue
                                  : Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Newest ID First',
                        style: TextStyle(
                          color:
                              controller.selectedSort.value == 'booking_id_desc'
                                  ? Colors.blue
                                  : null,
                          fontWeight:
                              controller.selectedSort.value == 'booking_id_desc'
                                  ? FontWeight.w600
                                  : null,
                        ),
                      ),
                      const Spacer(),
                      if (controller.selectedSort.value == 'booking_id_desc')
                        const Icon(Icons.check, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'date_desc',
                  child: Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 16,
                          color: controller.selectedSort.value == 'date_desc'
                              ? Colors.blue
                              : Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Latest Date',
                        style: TextStyle(
                          color: controller.selectedSort.value == 'date_desc'
                              ? Colors.blue
                              : null,
                          fontWeight:
                              controller.selectedSort.value == 'date_desc'
                                  ? FontWeight.w600
                                  : null,
                        ),
                      ),
                      const Spacer(),
                      if (controller.selectedSort.value == 'date_desc')
                        const Icon(Icons.check, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'date_asc',
                  child: Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 16,
                          color: controller.selectedSort.value == 'date_asc'
                              ? Colors.blue
                              : Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Earliest Date',
                        style: TextStyle(
                          color: controller.selectedSort.value == 'date_asc'
                              ? Colors.blue
                              : null,
                          fontWeight:
                              controller.selectedSort.value == 'date_asc'
                                  ? FontWeight.w600
                                  : null,
                        ),
                      ),
                      const Spacer(),
                      if (controller.selectedSort.value == 'date_asc')
                        const Icon(Icons.check, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'venue_name',
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16,
                          color: controller.selectedSort.value == 'venue_name'
                              ? Colors.blue
                              : Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Venue Name',
                        style: TextStyle(
                          color: controller.selectedSort.value == 'venue_name'
                              ? Colors.blue
                              : null,
                          fontWeight:
                              controller.selectedSort.value == 'venue_name'
                                  ? FontWeight.w600
                                  : null,
                        ),
                      ),
                      const Spacer(),
                      if (controller.selectedSort.value == 'venue_name')
                        const Icon(Icons.check, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            )),
        // Refresh button
        IconButton(
          onPressed: controller.refreshBookings,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSortIndicator() {
    return Obx(() {
      String sortText;
      IconData sortIcon;

      switch (controller.selectedSort.value) {
        case 'booking_id_desc':
          sortText = 'Sorted by: Newest ID First';
          sortIcon = Icons.tag;
          break;
        case 'date_desc':
          sortText = 'Sorted by: Latest Date';
          sortIcon = Icons.schedule;
          break;
        case 'date_asc':
          sortText = 'Sorted by: Earliest Date';
          sortIcon = Icons.schedule;
          break;
        case 'venue_name':
          sortText = 'Sorted by: Venue Name';
          sortIcon = Icons.location_on;
          break;
        default:
          sortText = 'Sorted by: Default';
          sortIcon = Icons.sort;
      }

      return Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(sortIcon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              sortText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
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
