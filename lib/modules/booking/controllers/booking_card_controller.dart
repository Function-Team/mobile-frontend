import 'dart:async';
import 'package:get/get.dart';
import '../widgets/booking_card.dart'; // Import untuk mengakses enum BookingStatus

class BookingCardController extends GetxController {
  // Timer properties
  Rx<Duration?> remainingTime = Rx<Duration?>(null);
  Timer? _timer;
  final String bookingId;
  final Rx<BookingStatus> status = Rx<BookingStatus>(BookingStatus.pending);

  BookingCardController(
      {required this.bookingId,
      BookingStatus initialStatus = BookingStatus.pending}) {
    status.value = initialStatus;
  }

  void startTimer(Duration initialDuration) {
    remainingTime.value = initialDuration;

    // Gunakan interval tepat 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value != null && remainingTime.value!.inSeconds > 0) {
        // Kurangi tepat 1 detik
        remainingTime.value =
            Duration(seconds: remainingTime.value!.inSeconds - 1);
      } else {
        _timer?.cancel();
        remainingTime.value = Duration.zero;

        // Ubah status menjadi expired ketika timer habis
        status.value = BookingStatus.expired;

        // Opsional: Tambahkan notifikasi atau callback
        //TODO: add Notification when booking expired
        // Get.snackbar(
        //   'Booking Expired',
        //   'Your booking with ID $bookingId has expired',
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: const Duration(seconds: 3),
        // );
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
