import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
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
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSortIndicator(context),
          _buildTabBar(),
          Expanded(
            child: _buildBookingList(),
          ),
        ],
      ),
    );
  }

  // Extract AppBar to separate method
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        LocalizationHelper.tr(LocaleKeys.bookingList_title),
        style: Theme.of(context)
            .textTheme
            .displaySmall!
            .copyWith(color: Colors.white),
      ),
      actions: [
        _buildSortButton(context),
        _buildRefreshButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  // Extract sort button to separate method
  Widget _buildSortButton(BuildContext context) {
    return Obx(() => PopupMenuButton<String>(
          icon: Stack(
            children: [
              Icon(
                controller.getCurrentSortIcon(),
                color: Colors.white,
              ),
              if (controller.isSortActive) _buildActiveIndicator(),
            ],
          ),
          tooltip: LocalizationHelper.tr(LocaleKeys.bookingList_sortBookings),
          onSelected: controller.setSortOption,
          itemBuilder: (context) => _buildSortMenuItems(context),
        ));
  }

  // Extract refresh button to separate method
  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: controller.refreshBookings,
      icon: const Icon(Icons.refresh, color: Colors.white),
      tooltip: LocalizationHelper.tr(LocaleKeys.bookingList_refreshBookings),
    );
  }

  // Extract active indicator to separate method
  Widget _buildActiveIndicator() {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Extract menu items to separate method
  List<PopupMenuEntry<String>> _buildSortMenuItems(BuildContext context) {
    return controller.sortOptions
        .map((option) => PopupMenuItem<String>(
              value: option['value'] as String,
              child: _buildSortMenuItem(context, option),
            ))
        .toList();
  }

  // Extract individual menu item to separate method
  Widget _buildSortMenuItem(BuildContext context, Map<String, dynamic> option) {
    final isSelected = controller.selectedSort.value == option['value'];

    return Row(
      children: [
        Icon(
          option['icon'] as IconData,
          size: 18,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          option['label'] as String,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        if (isSelected)
          Icon(
            Icons.check,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
      ],
    );
  }

  // Extract sort indicator to separate method
  Widget _buildSortIndicator(BuildContext context) {
    return Obx(() {
      if (!controller.isSortActive) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              controller.getCurrentSortIcon(),
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              LocalizationHelper.trArgs(LocaleKeys.bookingList_sortedBy, {'sortLabel': controller.getCurrentSortLabel()}),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _buildResetButton(context),
          ],
        ),
      );
    });
  }

  // Extract reset button to separate method
  Widget _buildResetButton(BuildContext context) {
    return GestureDetector(
      onTap: controller.clearSort,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocalizationHelper.tr(LocaleKeys.bookingList_reset),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.refresh,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  // Extract tab bar to separate method
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

  // Extract individual tab button to separate method
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

  // Extract booking list to separate method
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

  // Extract error state to separate method
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            LocalizationHelper.tr(LocaleKeys.bookingList_failedToLoad),
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
            child: Text(LocalizationHelper.tr(LocaleKeys.bookingList_retry)),
          ),
        ],
      ),
    );
  }

  // Extract empty state to separate method
  Widget _buildEmptyState() {
    String title;
    String message;
    IconData icon;

    switch (controller.currentTabIndex.value) {
      case 0:
        title = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noBookings_title);
        message = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noBookings_message);
        icon = Icons.calendar_today;
        break;
      case 1:
        title = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noPending_title);
        message = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noPending_message);
        icon = Icons.pending;
        break;
      case 2:
        title = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noConfirmed_title);
        message = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noConfirmed_message);
        icon = Icons.check_circle;
        break;
      case 3:
        title = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noCompleted_title);
        message = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noCompleted_message);
        icon = Icons.done_all;
        break;
      case 4:
        title = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noCancelled_title);
        message = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noCancelled_message);
        icon = Icons.cancel;
        break;
      default:
        title = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noResults_title);
        message = LocalizationHelper.tr(LocaleKeys.bookingList_emptyStates_noResults_message);
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
              child: Text(LocalizationHelper.tr(LocaleKeys.bookingList_exploreVenues)),
            ),
          ],
        ],
      ),
    );
  }

  // Extract navigation methods
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
