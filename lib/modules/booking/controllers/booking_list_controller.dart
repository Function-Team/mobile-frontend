import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/modules/notification/controllers/notification_controllers.dart';
import 'package:get/get.dart';

class BookingListController extends GetxController {
  final BookingService _bookingService = BookingService();
  late final AuthController _authController;

  final bookings = <BookingModel>[].obs;
  final filteredBookings = <BookingModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Track current user ID to detect account switches
  int? _currentUserId;

  final currentTabIndex = 0.obs;
  List<String> get tabTitles => [
        LocalizationHelper.tr(LocaleKeys.bookingList_tabs_all),
        LocalizationHelper.tr(LocaleKeys.bookingList_tabs_pending),
        LocalizationHelper.tr(LocaleKeys.bookingList_tabs_confirmed),
        LocalizationHelper.tr(LocaleKeys.bookingList_tabs_completed),
        LocalizationHelper.tr(LocaleKeys.bookingList_tabs_cancelled)
      ];

  final allCount = 0.obs;
  final pendingCount = 0.obs;
  final confirmedCount = 0.obs;
  final completedCount = 0.obs;
  final cancelledCount = 0.obs;

  // Sorting and filtering
  final selectedSort = 'booking_id_desc'.obs;
  final searchQuery = ''.obs;

  // Sort options for dropdown
  List<Map<String, dynamic>> get sortOptions => [
        {
          'value': 'booking_id_desc',
          'label': LocalizationHelper.tr(
              LocaleKeys.bookingList_sortOptions_newestIdFirst),
          'icon': Icons.arrow_downward
        },
        {
          'value': 'booking_id_asc',
          'label': LocalizationHelper.tr(
              LocaleKeys.bookingList_sortOptions_oldestIdFirst),
          'icon': Icons.arrow_upward
        },
        {
          'value': 'date_desc',
          'label': LocalizationHelper.tr(
              LocaleKeys.bookingList_sortOptions_latestDate),
          'icon': Icons.schedule
        },
        {
          'value': 'date_asc',
          'label': LocalizationHelper.tr(
              LocaleKeys.bookingList_sortOptions_earliestDate),
          'icon': Icons.history
        },
        {
          'value': 'venue_name',
          'label': LocalizationHelper.tr(
              LocaleKeys.bookingList_sortOptions_venueNameAZ),
          'icon': Icons.sort_by_alpha
        },
      ];

  @override
  void onInit() {
    super.onInit();

    // Get AuthController instance
    _authController = Get.find<AuthController>();

    // Set initial user ID
    _currentUserId = _authController.userId;

    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['initialTab'] != null) {
      final initialTab = arguments['initialTab'] as int;
      if (initialTab >= 0 && initialTab < tabTitles.length) {
        currentTabIndex.value = initialTab;
      }
    }

    // Listen to user changes and refresh bookings when user switches
    ever(_authController.user, (user) {
      final newUserId = user?.id;
      if (_currentUserId != newUserId) {
        print(
            'BookingListController: User changed from $_currentUserId to $newUserId, refreshing bookings...');
        _currentUserId = newUserId;

        // Add delay to prevent conflicts during logout process
        Future.delayed(const Duration(milliseconds: 100), () {
          if (newUserId != null) {
            // Only fetch if there's a valid user and controller is still active
            if (!Get.isRegistered<BookingListController>()) return;
            fetchBookings();
          } else {
            // Clear bookings if user logged out, but safely
            try {
              if (Get.isRegistered<BookingListController>()) {
                bookings.clear();
                filteredBookings.clear();
                updateBookingCounts();
              }
            } catch (e) {
              print(
                  'BookingListController: Error clearing bookings during logout: $e');
            }
          }
        });
      }
    });

    fetchBookings();
    _clearBookingNotifications();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final fetchedBookings = await _bookingService.getUserBookings();

      bookings.assignAll(fetchedBookings);
      updateBookingCounts();
      filterBookingsByTab();
      sortBookings();

      print('Loaded ${bookings.length} bookings successfully');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = LocalizationHelper.trArgs(
          'errors.failedToLoadBookings', {'error': e.toString()});
      showError(LocalizationHelper.tr(LocaleKeys.bookingList_failedToLoad));
      print('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() async {
    print('BookingListController: Refreshing bookings...');
    await _clearBookingNotifications();
    await fetchBookings();
  }

  Future<void> _clearBookingNotifications() async {
    try {
      final notificationController = Get.find<NotificationController>();
      await notificationController.clearNotifications();
      print('BookingListController: Cleared booking notifications');
    } catch (e) {
      print('BookingListController: Error clearing notifications: $e');
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
      case 'booking_id_desc':
        filteredBookings.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'booking_id_asc':
        filteredBookings.sort((a, b) => a.id.compareTo(b.id));
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

  // Helper methods for UI
  String getCurrentSortLabel() {
    final option = sortOptions.firstWhere(
      (option) => option['value'] == selectedSort.value,
      orElse: () => sortOptions.first,
    );
    return option['label'] as String;
  }

  IconData getCurrentSortIcon() {
    final option = sortOptions.firstWhere(
      (option) => option['value'] == selectedSort.value,
      orElse: () => sortOptions.first,
    );
    return option['icon'] as IconData;
  }

  // Check if using non-default sort
  bool get isSortActive => selectedSort.value != 'booking_id_desc';

  // Reset to default sort
  void clearSort() {
    selectedSort.value = 'booking_id_desc';
    sortBookings();
  }

  Future<void> cancelBooking(BookingModel booking) async {
    try {
      if (isBookingCompleted(booking)) {
        showError(
            LocalizationHelper.tr(LocaleKeys.booking_cannotCancelCompleted));
        return;
      }

      if (booking.isInCancelledSection) {
        showError(LocalizationHelper.tr(LocaleKeys.booking_alreadyCancelled));
        return;
      }

      await _bookingService.cancelBooking(booking.id);
      await refreshBookings();
      showSuccess(LocalizationHelper.tr(
          LocaleKeys.success_bookingCancelledSuccessfully));
    } catch (e) {
      showError(LocalizationHelper.trArgs(
          LocaleKeys.errors_failedToCancelBooking, {'error': e.toString()}));
    }
  }

  void showCancelConfirmationDialog(BookingModel booking) {
    if (isBookingCompleted(booking)) {
      showError(
          LocalizationHelper.tr(LocaleKeys.booking_cannotCancelCompleted));
      return;
    }

    if (booking.isInCancelledSection) {
      showError(LocalizationHelper.tr(LocaleKeys.booking_alreadyCancelled));
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text(LocalizationHelper.tr(LocaleKeys.booking_cancelBooking)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocalizationHelper.tr(
                LocaleKeys.booking_cancelConfirmationMessage)),
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.trArgs('booking.venueInfo', {
                'venueName': booking.place?.name ??
                    booking.placeName ??
                    LocalizationHelper.tr(LocaleKeys.common_unknown)
              }),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              LocalizationHelper.trArgs(
                  'booking.dateInfo', {'date': booking.formattedDate}),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalizationHelper.tr(LocaleKeys.booking_keepBooking)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              cancelBooking(booking);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(LocalizationHelper.tr(LocaleKeys.booking_yesCancel)),
          ),
        ],
      ),
    );
  }

  Future<void> createPaymentForBooking(BookingModel booking) async {
    if (!booking.isConfirmed) {
      showError(
          LocalizationHelper.tr(LocaleKeys.errors_bookingMustBeConfirmed));
      return;
    }

    if (isBookingCompleted(booking)) {
      showError(LocalizationHelper.tr(LocaleKeys.errors_bookingAlreadyPaid));
      return;
    }

    if (booking.isInCancelledSection) {
      showError(
          LocalizationHelper.tr(LocaleKeys.errors_cannotPayCancelledBooking));
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
      showError(LocalizationHelper.trArgs(
          LocaleKeys.errors_failedToCreatePayment, {'error': e.toString()}));
    }
  }

  void showSuccess(String message) {
    final context = Get.context;
    if (context != null && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: SnackbarType.success,
        autoClear: true,
        enableDebounce: false,
      );
    }
  }

  void showError(String message) {
    final context = Get.context;
    if (context != null && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false,
      );
    }
  }

  void navigateToBookingDetail(BookingModel booking) {
    Get.toNamed(MyRoutes.bookingDetail, arguments: booking.id);
  }

  void navigateToVenueDetail(BookingModel booking) {
    if (booking.place?.id != null) {
      Get.toNamed(MyRoutes.venueDetail, arguments: {
        'venueId': booking.place!.id,
      });
    }
  }
   void goToHome() {
      Get.find<BottomNavController>().changePage(0);
    }
}
