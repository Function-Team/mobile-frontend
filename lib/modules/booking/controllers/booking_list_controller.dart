import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:get/get.dart';

class BookingListController extends GetxController {
  final BookingService _bookingService = BookingService();

  final bookings = <BookingModel>[].obs;
  final filteredBookings = <BookingModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final currentTabIndex = 0.obs;
  final tabTitles = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  final allCount = 0.obs;
  final pendingCount = 0.obs;
  final confirmedCount = 0.obs;
  final completedCount = 0.obs;
  final cancelledCount = 0.obs;

  // Sorting and filtering
  final selectedSort = 'date_desc'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('🔄 Fetching user bookings...');
      final fetchedBookings = await _bookingService.getUserBookings();

      bookings.assignAll(fetchedBookings);
      updateBookingCounts();
      filterBookingsByTab();
      sortBookings();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load bookings: ${e.toString()}';
      showError('Failed to load bookings');
    } finally {
      isLoading.value = false;
    }
  }

  void updateBookingCounts() {
    allCount.value = bookings.length;

    pendingCount.value = bookings
        .where(
            (b) => b.status == BookingStatus.pending && !isBookingCompleted(b))
        .length;

    confirmedCount.value = bookings
        .where((b) =>
            b.status == BookingStatus.confirmed && !isBookingCompleted(b))
        .length;

    completedCount.value = bookings.where((b) => isBookingCompleted(b)).length;

    // Count untuk cancelled section
    cancelledCount.value = bookings.where((b) => b.isInCancelledSection).length;
  }

  int getTabCount(int index) {
    switch (index) {
      case 0:
        return allCount.value;
      case 1:
        return pendingCount.value;
      case 2:
        return confirmedCount.value;
      case 3:
        return completedCount.value;
      case 4:
        return cancelledCount.value;
      default:
        return 0;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    filterBookingsByTab();
    sortBookings();
  }

  bool isBookingCompleted(BookingModel booking) {
    return booking.isConfirmed && booking.isPaid;
  }

  void filterBookingsByTab() {
    List<BookingModel> filtered = [];

    switch (currentTabIndex.value) {
      case 0:
        filtered = List.from(bookings);
        break;

      case 1:
        filtered = bookings
            .where((b) =>
                b.status == BookingStatus.pending &&
                !isBookingCompleted(b) &&
                !b.isInCancelledSection)
            .toList();
        break;

      case 2:
        filtered = bookings
            .where((b) =>
                b.status == BookingStatus.confirmed &&
                !isBookingCompleted(b) &&
                !b.isInCancelledSection)
            .toList();
        break;

      case 3:
        filtered = bookings.where((b) => isBookingCompleted(b)).toList();
        break;

      case 4:
        filtered = bookings.where((b) => b.isInCancelledSection).toList();
        break;
    }

    // Apply search filter if active
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((booking) {
        final venueName =
            (booking.place?.name ?? booking.placeName ?? '').toLowerCase();
        final bookingId = booking.id.toString();
        return venueName.contains(query) || bookingId.contains(query);
      }).toList();
    }

    filteredBookings.assignAll(filtered);
  }

  void sortBookings() {
    switch (selectedSort.value) {
      case 'date_desc':
        filteredBookings
            .sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
        break;
      case 'date_asc':
        filteredBookings
            .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
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
    sortBookings();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterBookingsByTab();
  }

  Future<void> refreshBookings() async {
    await fetchBookings();
  }

  Future<void> cancelBooking(BookingModel booking) async {
    try {
      if (isBookingCompleted(booking)) {
        showError('Cannot cancel a completed booking');
        return;
      }

      if (booking.isInCancelledSection) {
        showError('This booking is already cancelled');
        return;
      }

      await _bookingService.cancelBooking(booking.id);
      await refreshBookings();
      showSuccess('Booking cancelled successfully!');
    } catch (e) {
      showError('Failed to cancel booking: ${e.toString()}');
    }
  }

  void showCancelConfirmationDialog(BookingModel booking) {
    if (isBookingCompleted(booking)) {
      showError('Cannot cancel a completed booking');
      return;
    }

    if (booking.isInCancelledSection) {
      showError('This booking is already cancelled');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 8),
            Text(
              'Venue: ${booking.place?.name ?? booking.placeName ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Date: ${booking.formattedDate}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Booking'),
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

  Future<void> createPaymentForBooking(BookingModel booking) async {
    if (!booking.isConfirmed) {
      showError('Booking must be confirmed by admin before payment');
      return;
    }

    if (isBookingCompleted(booking)) {
      showError('This booking is already paid');
      return;
    }

    if (booking.isInCancelledSection) {
      showError('Cannot make payment for cancelled booking');
      return;
    }

    try {
      if (Get.isRegistered<BookingController>()) {
        final bookingController = Get.find<BookingController>();
        await bookingController.createPaymentForBooking(booking);
      } else {
        Get.put(BookingController());
        final bookingController = Get.find<BookingController>();
        await bookingController.createPaymentForBooking(booking);
      }

      await Future.delayed(const Duration(seconds: 2));
      await refreshBookings();
    } catch (e) {
      showError('Failed to create payment: ${e.toString()}');
    }
  }

  void showSuccess(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.success,
      );
    }
  }

  void showError(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.error,
      );
    }
  }
}
