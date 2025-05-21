import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class BookingListController extends GetxController {
  final BookingService _bookingService = BookingService();
  final VenueRepository _venueRepository = VenueRepository();
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> refreshBookings() async {
    bookings.clear();
    await fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      final bookingsData = await _bookingService.getBookings();
      bookings.clear();

      for (var bookingData in bookingsData) {
        final venueId = bookingData['venue_id'];
        if (venueId != null) {
          final venue = await _venueRepository.getVenueById(venueId);
          if (venue != null) {
            bookings.add(BookingModel(
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
            ));
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
