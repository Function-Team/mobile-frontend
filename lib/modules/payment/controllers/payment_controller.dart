import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/payment/services/payment_service.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart'
    as payment;
import 'package:function_mobile/modules/booking/models/booking_model.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<payment.PaymentModel?> currentPayment =
      Rx<payment.PaymentModel?>(null);
  final Rx<payment.PaymentStatus> paymentStatus =
      payment.PaymentStatus.pending.obs;
  final RxList<payment.PaymentModel> paymentHistory =
      <payment.PaymentModel>[].obs;
  final RxBool isPaymentProcessing = false.obs;
  final RxString snapToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentHistory();
  }

  // Initialize payment - Backend handles all calculations
  Future<bool> initializePayment(BookingModel booking) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (booking.id == null) {
        throw Exception('Invalid booking ID');
      }

      // Get amount from booking or calculate it
      final amount = booking.place?.price?.toDouble() ?? 0.0;

      // Create payment with amount
      final response = await _paymentService.createPayment(
        booking.id!,
        amount: amount,
      );

      snapToken.value = response.snapToken ?? '';
      paymentStatus.value = payment.PaymentStatus.pending;
      currentPayment.value = response.paymentModel;

      Get.snackbar(
        'Payment Initialized',
        'Amount: Rp ${_formatCurrency(amount)}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to initialize payment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Start Midtrans payment process
  Future<bool> startPaymentProcess() async {
  try {
    isPaymentProcessing.value = true;

    print('[PaymentController] Starting payment with snapToken: ${snapToken.value}');

    if (snapToken.value.isEmpty) {
      throw Exception('No payment session available');
    }

    final result = await _paymentService.startPayment(snapToken: snapToken.value);
    print('[PaymentController] Midtrans result: $result');

    final status = _paymentService.handlePaymentResult(result);
    paymentStatus.value = status;

    print('[PaymentController] Parsed payment status: $status');

    if (status == payment.PaymentStatus.success) {
      print('[PaymentController] Payment success detected. Triggering success handler.');
      _handlePaymentSuccess();
      return true;
    } else {
      print('[PaymentController] Payment failed or cancelled. Status: $status');
      _handlePaymentFailure(status);
      return false;
    }
  } catch (e, stackTrace) {
    print('[PaymentController] Exception during startPaymentProcess: $e');
    print('[PaymentController] StackTrace: $stackTrace');
    paymentStatus.value = payment.PaymentStatus.failed;
    _showErrorSnackbar('Payment Failed', e.toString());
    return false;
  } finally {
    isPaymentProcessing.value = false;
  }
}


  // Retry payment
  Future<bool> retryPayment() async {
    if (snapToken.value.isNotEmpty) {
      return await startPaymentProcess();
    } else {
      _showErrorSnackbar('Error',
          'No payment session available. Please restart the booking process.');
      return false;
    }
  }

  // Cancel payment
  Future<void> cancelPayment() async {
    try {
      paymentStatus.value = payment.PaymentStatus.cancelled;
      _resetPaymentState();

      _showInfoSnackbar(
          'Payment Cancelled', 'Your payment has been cancelled.');
      Get.back();
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to cancel payment');
    }
  }

  // Load payment history
  Future<void> loadPaymentHistory() async {
    try {
      isLoading.value = true;
      final payments = await _paymentService.getAllPayments();
      paymentHistory.value = payments;
    } catch (e) {
      errorMessage.value = 'Failed to load payment history: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh payment status
  Future<void> refreshPaymentStatus(int paymentId) async {
  try {
    final status = await _paymentService.checkPaymentStatus(paymentId);
    paymentStatus.value = status;
    final paymentModel = await _paymentService.getPayment(paymentId);
    currentPayment.value = paymentModel;

    print('[PaymentController] Updated payment status: $status');
  } catch (e) {
    print('[PaymentController] Error refreshing payment status: $e');
  }
}
  // Get payment by ID
  Future<payment.PaymentModel?> getPaymentById(int paymentId) async {
    try {
      return await _paymentService.getPayment(paymentId);
    } catch (e) {
      return null;
    }
  }

  // Helper methods for UI
  Color getPaymentStatusColor(payment.PaymentModel paymentModel) {
    final status =
        payment.PaymentStatusExtension.fromString(paymentModel.status) ??
            payment.PaymentStatus.pending;
    return status.color;
  }

  String getPaymentStatusText(payment.PaymentModel paymentModel) {
    final status =
        payment.PaymentStatusExtension.fromString(paymentModel.status) ??
            payment.PaymentStatus.pending;
    return status.displayText;
  }

  IconData getPaymentStatusIcon(payment.PaymentModel paymentModel) {
    final status =
        payment.PaymentStatusExtension.fromString(paymentModel.status) ??
            payment.PaymentStatus.pending;
    return status.icon;
  }

  // Private helper methods
  void _handlePaymentSuccess() {
  print('[PaymentController] Handling payment success...');

  paymentStatus.value = payment.PaymentStatus.success;
  _showSuccessSnackbar('Payment Successful!', 'Your booking has been confirmed.');
  print('[PaymentController] Redirecting to /booking-success');
  Get.offAllNamed('/booking-success');
}


  void _handlePaymentFailure(payment.PaymentStatus status) {
    String message = 'Payment failed. Please try again.';

    switch (status) {
      case payment.PaymentStatus.expired:
        message = 'Payment session expired. Please restart the payment.';
        break;
      case payment.PaymentStatus.cancelled:
        message = 'Payment was cancelled.';
        break;
      case payment.PaymentStatus.failed:
        message = 'Payment failed. Please check your payment method.';
        break;
      default:
        break;
    }

    _showErrorSnackbar('Payment Failed', message);
  }

  void _resetPaymentState() {
    currentPayment.value = null;
    paymentStatus.value = payment.PaymentStatus.pending;
    snapToken.value = '';
    errorMessage.value = '';
    isLoading.value = false;
    isPaymentProcessing.value = false;
  }

  // Utility methods
  String _formatCurrency(double amount) {
    return 'IDR ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}