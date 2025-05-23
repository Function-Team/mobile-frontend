import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/widgets/booking_card.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:get/get.dart';

class BookingsListPage extends GetView<BookingListController> {
  const BookingsListPage({super.key});

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

        return _buildBookingsList(context);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'My Bookings',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (String value) {
            controller.setSortOption(value);
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'date_desc',
              child: Text('Latest First'),
            ),
            const PopupMenuItem(
              value: 'date_asc',
              child: Text('Oldest First'),
            ),
            const PopupMenuItem(
              value: 'venue_name',
              child: Text('Venue Name'),
            ),
            const PopupMenuItem(
              value: 'status',
              child: Text('Status'),
            ),
          ],
        ),
      ],
      bottom: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(48),
    child: Container(
      color: Theme.of(Get.context!).colorScheme.primary,
      child: TabBar(
        controller: controller.tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        isScrollable: true, // Membuat tab bisa di-scroll jika terlalu panjang
        tabAlignment: TabAlignment.start,
        tabs: [
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  'All (${controller.bookings.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  'Pending (${controller.pendingCount.value})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  'Confirmed (${controller.confirmedCount.value})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  'Expired (${controller.expiredCount.value})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ],
      ),
    ),
  );
}

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your bookings...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: controller.refreshBookings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(Get.context!).size.height * 0.7,
          child: Center(
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
                  'Failed to load bookings',
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
                  onPressed: controller.refreshBookings,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        _buildBookingsTab(controller.bookings),
        _buildBookingsTab(controller.bookings
            .where((b) => b.status == BookingStatus.pending)
            .toList()),
        _buildBookingsTab(controller.bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList()),
        _buildBookingsTab(controller.bookings
            .where((b) => b.status == BookingStatus.expired)
            .toList()),
      ],
    );
  }

  Widget _buildBookingsTab(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: controller.refreshBookings,
      child: Column(
        children: [
          // Booking count and filter info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.getBookingCountText(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    )),
                TextButton.icon(
                  onPressed: () => _showFilterDialog(Get.context!),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),

          // Bookings list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BookingCard(
                    booking: booking,
                    onTap: () => controller.goToBookingDetail(booking),
                    onCancel: () =>
                        controller.showCancelConfirmationDialog(booking),
                    onViewVenue: () => controller.goToVenueDetail(booking),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subMessage;
    IconData icon;

    switch (controller.currentTabIndex.value) {
      case 1: // Pending
        icon = Icons.schedule;
        message = 'No pending bookings';
        subMessage = 'Your pending bookings will appear here';
        break;
      case 2: // Confirmed
        icon = Icons.check_circle_outline;
        message = 'No confirmed bookings';
        subMessage = 'Your confirmed bookings will appear here';
        break;
      case 3: // Expired
        icon = Icons.access_time;
        message = 'No expired bookings';
        subMessage = 'Your expired bookings will appear here';
        break;
      default: // All
        icon = Icons.event_busy;
        message = 'No bookings yet';
        subMessage = 'Start booking amazing venues!';
    }

    return RefreshIndicator(
      onRefresh: controller.refreshBookings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(Get.context!).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                if (controller.currentTabIndex.value == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: PrimaryButton(
                        width: 200,
                        leftIcon: Icons.search,
                        text: 'Search Venue',
                        onPressed: () {
                          Get.offAllNamed(MyRoutes.bottomNav);
                          Get.find<BottomNavController>().changePage(0);
                        }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Bookings'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by venue name, location, or date...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: controller.searchBookings,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearSearch();
              Get.back();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sort by',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Latest First'),
                      value: 'date_desc',
                      groupValue: controller.selectedSort.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setSortOption(value);
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Oldest First'),
                      value: 'date_asc',
                      groupValue: controller.selectedSort.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setSortOption(value);
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Venue Name'),
                      value: 'venue_name',
                      groupValue: controller.selectedSort.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setSortOption(value);
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Status'),
                      value: 'status',
                      groupValue: controller.selectedSort.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setSortOption(value);
                        }
                      },
                    ),
                  ],
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
