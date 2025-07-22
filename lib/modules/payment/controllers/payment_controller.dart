import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/payment/services/payment_service.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart' as payment;
import 'package:function_mobile/modules/booking/models/booking_model.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<payment.PaymentModel?> currentPayment = Rx<payment.PaymentModel?>(null);
  final Rx<payment.PaymentStatus> paymentStatus = payment.PaymentStatus.pending.obs;
  final RxList<payment.PaymentModel> paymentHistory = <payment.PaymentModel>[].obs;
  
  // Payment process variables
  final RxBool isPaymentProcessing = false.obs;
  final RxString snapToken = ''.obs;
  final RxDouble paymentAmount = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadPaymentHistory();
  }

  // Initialize payment for a booking
  Future<bool> initializePayment(BookingModel booking) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      if (booking.id == null) {
        throw Exception('Invalid booking ID');
      }
      
      // Calculate payment amount from booking
      paymentAmount.value = _calculateAmountFromBooking(booking);
      
      // Create payment in backend
      final payment.PaymentResponse response = await _paymentService.createPayment(booking.id!);
      
      currentPayment.value = response.payment;
      snapToken.value = response.midtrans.token;
      paymentStatus.value = payment.PaymentStatus.pending;
      
      Get.snackbar(
        'Payment Initialized',
        'Payment has been initialized. Proceed to payment.',
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

  // Calculate amount from booking data
  double _calculateAmountFromBooking(BookingModel booking) {
    // Extract price from place object or use default
    if (booking.place?.price != null) {
      return booking.place!.price!.toDouble();
    }
    return 0.0; // Default amount
  }

  // Start Midtrans payment process
  Future<bool> startPaymentProcess() async {
    try {
      isPaymentProcessing.value = true;
      errorMessage.value = '';
      
      if (snapToken.value.isEmpty) {
        throw Exception('No payment token available');
      }
      
      // Start Midtrans payment UI
      final result = await _paymentService.startPayment(
        snapToken: snapToken.value,
      );
      
      if (result != null) {
        // Handle payment result
        final payment.PaymentStatus status = _paymentService.handlePaymentResult(result);
        paymentStatus.value = status;
        
        // Update UI based on result
        await _handlePaymentResult(result);
        
        return status == payment.PaymentStatus.success;
      }
      
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Payment Error',
        'Payment failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isPaymentProcessing.value = false;
    }
  }

  // Handle payment result from Midtrans
  Future<void> _handlePaymentResult(dynamic result) async {
    // This would be implemented based on actual Midtrans response
    // For now, simulate different outcomes
    
    Get.snackbar(
      'Payment Completed',
      'Your payment has been processed.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // Navigate to success page
    Get.offAllNamed('/booking-success');
  }

  // Refresh payment status from backend
  Future<void> refreshPaymentStatus(int paymentId) async {
    try {
      final payment.PaymentStatus status = await _paymentService.checkPaymentStatus(paymentId);
      paymentStatus.value = status;
      
      // Update current payment
      final paymentModel = await _paymentService.getPayment(paymentId);
      currentPayment.value = paymentModel;
      
    } catch (e) {
      print('Error refreshing payment status: $e');
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

  // Retry payment
  Future<bool> retryPayment() async {
    if (snapToken.value.isNotEmpty) {
      return await startPaymentProcess();
    } else {
      Get.snackbar(
        'Error',
        'No payment session available. Please restart the booking process.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Cancel payment
  Future<void> cancelPayment() async {
    try {
      paymentStatus.value = payment.PaymentStatus.cancelled;
      snapToken.value = '';
      currentPayment.value = null;
      
      Get.snackbar(
        'Payment Cancelled',
        'Your payment has been cancelled.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
      // Navigate back
      Get.back();
    } catch (e) {
      print('Error cancelling payment: $e');
    }
  }

  // Get payment status color
  Color getPaymentStatusColor(payment.PaymentStatus status) {
    switch (status) {
      case payment.PaymentStatus.success:
        return Colors.green;
      case payment.PaymentStatus.pending:
        return Colors.orange;
      case payment.PaymentStatus.failed:
      case payment.PaymentStatus.cancelled:
        return Colors.red;
      case payment.PaymentStatus.expired:
        return Colors.grey;
    }
  }

  // Get payment status text
  String getPaymentStatusText(payment.PaymentStatus status) {
    switch (status) {
      case payment.PaymentStatus.success:
        return 'Success';
      case payment.PaymentStatus.pending:
        return 'Pending';
      case payment.PaymentStatus.failed:
        return 'Failed';
      case payment.PaymentStatus.cancelled:
        return 'Cancelled';
      case payment.PaymentStatus.expired:
        return 'Expired';
    }
  }

  // Get payment status icon
  IconData getPaymentStatusIcon(payment.PaymentStatus status) {
    switch (status) {
      case payment.PaymentStatus.success:
        return Icons.check_circle;
      case payment.PaymentStatus.pending:
        return Icons.access_time;
      case payment.PaymentStatus.failed:
      case payment.PaymentStatus.cancelled:
        return Icons.error;
      case payment.PaymentStatus.expired:
        return Icons.schedule;
    }
  }

  // Clear payment data
  void clearPaymentData() {
    currentPayment.value = null;
    snapToken.value = '';
    paymentStatus.value = payment.PaymentStatus.pending;
    paymentAmount.value = 0.0;
    errorMessage.value = '';
  }
}