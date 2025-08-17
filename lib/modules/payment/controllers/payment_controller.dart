import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
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

      // Get amount from booking or calculate it
      final amount = booking.place?.price?.toDouble() ?? 0.0;

      // First try to get existing payment, then create new one if needed
      payment.PaymentResponse response;
      try {
        // Try to get existing payment first
        response = await _paymentService.getPaymentByBookingId(booking.id);
        print('Found existing payment for booking ${booking.id}');
      } catch (e) {
        // If no existing payment found, create a new one
        print(
            'No existing payment found, creating new payment for booking ${booking.id}');
        response = await _paymentService.createPayment(
          booking.id,
          amount: amount,
        );
      }

      snapToken.value = response.snapToken ?? '';
      paymentStatus.value = payment.PaymentStatus.pending;
      currentPayment.value = response.paymentModel;

      CustomSnackbar.show(
          context: Get.context!,
          message: 'Payment Initialized, Amount: Rp ${_formatCurrency(amount)}',
          type: SnackbarType.success);

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Failed to initialize payment: ${e.toString()}',
          type: SnackbarType.error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Start Midtrans payment process
  Future<bool> startPaymentProcess() async {
    try {
      isPaymentProcessing.value = true;

      print(
          '[PaymentController] Starting payment with snapToken: ${snapToken.value}');

      if (snapToken.value.isEmpty) {
        throw Exception('No payment session available');
      }

      // Show loading message
      _showInfoSnackbar('Redirecting', 'Opening Midtrans payment page...');

      final result =
          await _paymentService.startPayment(snapToken: snapToken.value);
      print('[PaymentController] Midtrans result: $result');

      final status = _paymentService.handlePaymentResult(result);
      paymentStatus.value = status;

      print('[PaymentController] Parsed payment status: $status');

      // Refresh payment status from backend after webview closes
      if (currentPayment.value != null) {
        await _refreshPaymentFromBackend();
      }

      if (status == payment.PaymentStatus.success) {
        print(
            '[PaymentController] Payment success detected. Triggering success handler.');
        _handlePaymentSuccess();
        return true;
      } else if (status == payment.PaymentStatus.pending) {
        print(
            '[PaymentController] Payment pending. Checking backend status...');
        // For pending status, we should check the actual status from backend
        await Future.delayed(const Duration(seconds: 2));
        await _refreshPaymentFromBackend();

        if (paymentStatus.value == payment.PaymentStatus.success) {
          _handlePaymentSuccess();
          return true;
        } else {
          _handlePaymentFailure(paymentStatus.value);
          return false;
        }
      } else {
        print(
            '[PaymentController] Payment failed or cancelled. Status: $status');
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

  // Refresh payment status from backend
  Future<void> _refreshPaymentFromBackend() async {
    try {
      if (currentPayment.value != null && currentPayment.value!.id != null) {
        final updatedStatus =
            await _paymentService.checkPaymentStatus(currentPayment.value!.id!);
        paymentStatus.value = updatedStatus;
        print(
            '[PaymentController] Updated payment status from backend: $updatedStatus');
      } else {
        print(
            '[PaymentController] Cannot refresh payment status: payment or payment ID is null');
      }
    } catch (e) {
      print('[PaymentController] Failed to refresh payment status: $e');
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
    _showSuccessSnackbar(
        'Payment Successful!', 'Your booking has been confirmed.');
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
    CustomSnackbar.show(
        context: Get.context!, message: message, type: SnackbarType.success);
  }

  void _showErrorSnackbar(String title, String message) {
    CustomSnackbar.show(
        context: Get.context!, message: message, type: SnackbarType.error);
  }

  void _showInfoSnackbar(String title, String message) {
    CustomSnackbar.show(
        context: Get.context!, message: message, type: SnackbarType.info);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
