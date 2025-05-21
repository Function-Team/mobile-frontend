import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class BookingDetailController extends GetxController {
  final BookingService _bookingService = BookingService();
  final VenueRepository _venueRepository = VenueRepository();
  final Rx<BookingModel?> booking = Rx<BookingModel?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookingDetail();
  }

  Future<void> fetchBookingDetail() async {
    try {
      isLoading.value = true;
      final bookingId = int.tryParse(Get.arguments?.toString() ?? '');

      if (bookingId != null) {
        final bookingsData = await _bookingService.getBookings();
        final bookingData = bookingsData.firstWhere(
          (booking) => booking['id'] == bookingId,
          orElse: () => <String, dynamic>{},
        );

        if (bookingData.isNotEmpty) {
          final venueId = bookingData['venue_id'];
          if (venueId != null) {
            final venue = await _venueRepository.getVenueById(venueId);
            if (venue != null) {
              booking.value = BookingModel(
                id: bookingData['id'],
                venue: venue,
                createdAt: DateTime.parse(bookingData['created_at']),
                dateRange: DateTimeRange(
                  start: DateTime.parse(bookingData['start_date']),
                  end: DateTime.parse(bookingData['end_date']),
                ),
                status: BookingStatus.values.firstWhere(
                  (e) => e.toString().split('.').last == bookingData['status'],
                  orElse: () => BookingStatus.pending,
                ),
              );
            }
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBooking() async {
    if (booking.value != null) {
      await _bookingService.removeBooking(booking.value!.id);
      final bookingListController = Get.find<BookingListController>();
      bookingListController.fetchBookings();
      Get.back();
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Booking berhasil dibatalkan',
          type: SnackbarType.success);
    }
  }
}
