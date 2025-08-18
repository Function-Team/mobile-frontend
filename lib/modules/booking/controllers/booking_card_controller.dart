import 'dart:async';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:get/get.dart';

class BookingCardController extends GetxController {
  Rxn<Duration> remainingTime = Rxn<Duration>();
  Timer? _timer;
  final Rx<BookingStatus> status = Rx<BookingStatus>(BookingStatus.pending);

  BookingCardController({BookingStatus initialStatus = BookingStatus.pending}) {
    status.value = initialStatus;

    ever(remainingTime, (time) {
      if (time != null && time <= Duration.zero) {
        _timer?.cancel();
        status.value = BookingStatus.expired;
        // Optional: Add notification when booking expires
      }
    });
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      decreaseTime();
    });
  }
  void initializeTimer(DateTime expiresAt) {
    final now = DateTime.now();
    final remaining = expiresAt.difference(now);

    if (remaining.isNegative) {
      remainingTime.value = Duration.zero;
      status.value = BookingStatus.expired;
      return;
    }

    remainingTime.value = remaining;
    startTimer();
  }

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
