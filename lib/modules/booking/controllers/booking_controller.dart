import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/booking/widgets/change_booking_bottom_sheets.dart';
import 'package:function_mobile/modules/booking/widgets/detail_bottom_sheets.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';
import 'dart:async';

class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final RxString selectedCapacity = '10'.obs; // Nilai default '10'
  final RxList<String> capacityOptions = ['10', '20', '50', '100', '200'].obs;
  final RxInt remainingSeconds = 300.obs; // 5 menit
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Pastikan nilai default ada dalam daftar opsi
    if (!capacityOptions.contains(selectedCapacity.value)) {
      selectedCapacity.value = capacityOptions[0];
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
  }

  void setCapacity(String capacity) {
    selectedCapacity.value = capacity;
  }

  Future displayDetailBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (_) => DetailBottomSheets(),
    );
  }

  Future displayChangeDateBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeBookingBottomSheet(),
    );
  }

  void startTimer() {
    _timer?.cancel();
    remainingSeconds.value = 200;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void goToBookingListPage() {
    Get.offAllNamed(MyRoutes.bottomNav);
    Get.find<BottomNavController>().changePage(1);
    Get.find<BookingListController>().refreshBookings();
  }

  Future<void> saveBooking(VenueModel venue) async {
    // Buat ID unik untuk booking
    final bookingId = DateTime.now().millisecondsSinceEpoch;

    // Buat objek booking
    final booking = {
      'id': bookingId,
      'venue_id': venue.id,
      'venue_name': venue.name,
      'venue_image': venue.firstPictureUrl,
      'venue_price': venue.price,
      'capacity': selectedCapacity.value,
      'start_date': selectedDateRange.value?.start.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'end_date': selectedDateRange.value?.end.toIso8601String() ??
          DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };

    // Simpan booking ke secure storage
    await _bookingService.addBooking(booking);
    // startTimer();
    goToBookingListPage();
  }
}
