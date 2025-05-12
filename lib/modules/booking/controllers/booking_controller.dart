import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/widgets/change_booking_bottom_sheets.dart';
import 'package:function_mobile/modules/booking/widgets/detail_bottom_sheets.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  Rx<DateTimeRange?> selectedRange = Rx<DateTimeRange?>(null);
  RxString selectedCapacity = ''.obs;

  void setDateRange(DateTimeRange range) {
    selectedRange.value = range;
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
}
