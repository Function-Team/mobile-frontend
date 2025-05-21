import 'dart:async';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:get/get.dart';
import 'package:function_mobile/common/routes/routes.dart';

class BookingCardController extends GetxController {
  Rxn<Duration> remainingTime = Rxn<Duration>();
  Timer? _timer;
  final Rx<BookingStatus> status = Rx<BookingStatus>(BookingStatus.pending);

  BookingCardController({BookingStatus initialStatus = BookingStatus.pending}) {
    status.value = initialStatus;

    // Pantau perubahan waktu
    ever(remainingTime, (time) {
      if (time == Duration.zero) {
        _timer?.cancel();
        status.value = BookingStatus.expired;
        // TODO: add Notification when booking expired
      }
    });
  }

  void goToDetail(String bookingId) {
    Get.toNamed(MyRoutes.bookingDetail, arguments: bookingId);
  }

  void startTimer() {}

  void decreaseTime() {
    if (remainingTime.value != null && remainingTime.value!.inSeconds > 0) {
      remainingTime.value = remainingTime.value! - const Duration(seconds: 1);
    } else {
      remainingTime.value = Duration.zero;
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
