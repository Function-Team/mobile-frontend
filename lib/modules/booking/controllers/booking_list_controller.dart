import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:get/get.dart';

class BookingListController extends GetxController
    with GetTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();

  // State management
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter and sort options
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedSort = 'date_desc'.obs;

  // Tab controller for different booking statuses
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  // Filtered bookings based on current tab
  final RxList<BookingModel> filteredBookings = <BookingModel>[].obs;

  // Booking counts for each status
  final RxInt pendingCount = 0.obs;
  final RxInt confirmedCount = 0.obs;
  final RxInt expiredCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
      _filterBookingsByTab();
    });
    fetchBookings();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final fetchedBookings = await _bookingService.getUserBookings();
      bookings.assignAll(fetchedBookings);
      _updateBookingCounts();
      _filterBookingsByTab();
      _sortBookings();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load bookings: ${e.toString()}';
      print('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() async {
    bookings.clear();
    filteredBookings.clear();
    await fetchBookings();
  }

  void _updateBookingCounts() {
    pendingCount.value =
        bookings.where((b) => b.status == BookingStatus.pending).length;
    confirmedCount.value =
        bookings.where((b) => b.status == BookingStatus.confirmed).length;
    expiredCount.value =
        bookings.where((b) => b.status == BookingStatus.expired).length;
  }

  void _filterBookingsByTab() {
    switch (currentTabIndex.value) {
      case 0: // All
        filteredBookings.assignAll(bookings);
        break;
      case 1: // Pending
        filteredBookings.assignAll(
            bookings.where((b) => b.status == BookingStatus.pending).toList());
        break;
      case 2: // Confirmed
        filteredBookings.assignAll(bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList());
        break;
      case 3: // Expired
        filteredBookings.assignAll(
            bookings.where((b) => b.status == BookingStatus.expired).toList());
        break;
    }
  }

  void _sortBookings() {
    switch (selectedSort.value) {
      case 'date_desc':
        filteredBookings.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
        break;
      case 'date_asc':
        filteredBookings.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        break;
      case 'venue_name':
        filteredBookings.sort(
            (a, b) => (a.place?.name ?? '').compareTo(b.place?.name ?? ''));
        break;
      case 'status':
        filteredBookings
            .sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }
  }

  void setSortOption(String sortOption) {
    selectedSort.value = sortOption;
    _sortBookings();
  }

  Future<void> cancelBooking(BookingModel booking) async {
    try {
      await _bookingService.cancelBooking(booking.id);

      // Remove from local list
      bookings.removeWhere((b) => b.id == booking.id);

      _updateBookingCounts();
      _filterBookingsByTab();

      _showSuccess('Booking cancelled successfully!');
    } catch (e) {
      _showError('Failed to cancel booking: ${e.toString()}');
    }
  }

  void showCancelConfirmationDialog(BookingModel booking) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Are you sure you want to cancel this booking for ${booking.place?.name ?? 'this venue'}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              cancelBooking(booking);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // Filter methods
  List<BookingModel> getUpcomingBookings() {
    final now = DateTime.now();
    return bookings.where((booking) {
      final bookingDateTime = DateTime(
        int.parse(booking.startTime.split(':')[0]),
        int.parse(booking.startTime.split(':')[1]),
      );
      return bookingDateTime.isAfter(now) &&
          (booking.status == BookingStatus.confirmed ||
              booking.status == BookingStatus.pending);
    }).toList();
  }

  List<BookingModel> getPastBookings() {
    final now = DateTime.now();
    return bookings.where((booking) {
      final bookingDateTime = DateTime(
        int.parse(booking.endTime.split(':')[0]),
        int.parse(booking.endTime.split(':')[1]),
      );
      return bookingDateTime.isBefore(now);
    }).toList();
  }

  List<BookingModel> getBookingsForDate(DateTime date) {
    return bookings
        .where((booking) => booking.startDateTime.year == date.year &&
            booking.startDateTime.month == date.month &&
            booking.startDateTime.day == date.day)
        .toList();
  }

  // Navigation methods
  void goToBookingDetail(BookingModel booking) {
    Get.toNamed(
      MyRoutes.bookingDetail,
      arguments: booking.id,
    );
  }

  void goToVenueDetail(BookingModel booking) {
    if (booking.place?.id != null) {
      Get.toNamed(
        MyRoutes.venueDetail,
        arguments: {'venueId': booking.place!.id},
      );
    }
  }

  // Utility methods
  void _showSuccess(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.success,
      );
    }
  }

  void _showError(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.error,
      );
    }
  }

  String getBookingCountText() {
    if (filteredBookings.isEmpty) {
      return 'No bookings found';
    }
    return '${filteredBookings.length} booking${filteredBookings.length > 1 ? 's' : ''}';
  }

  // Search functionality
  final RxString searchQuery = ''.obs;
  final RxList<BookingModel> searchResults = <BookingModel>[].obs;

  void searchBookings(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final results = bookings.where((booking) {
      final venueName = booking.place?.name?.toLowerCase() ?? '';
      final venueAddress = booking.place?.address?.toLowerCase() ?? '';
      final searchTerm = query.toLowerCase();

      return venueName.contains(searchTerm) ||
          venueAddress.contains(searchTerm) ||
          booking.formattedDate.toLowerCase().contains(searchTerm);
    }).toList();

    searchResults.assignAll(results);
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }
}
