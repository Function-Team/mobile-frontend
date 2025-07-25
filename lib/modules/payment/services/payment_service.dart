import 'dart:convert';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:function_mobile/modules/payment/models/payment_model.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  // Create payment and get Snap token
  Future<PaymentResponse> createPayment(int bookingId) async {
    try {
      final request = PaymentCreateRequest(bookingId: bookingId);

      // Use your existing API service method signature
      final response = await _apiService.postRequest(
        'payment',
        request.toJson(), // Pass body as second parameter
      );

      if (response == null) {
        throw Exception('Failed to create payment: No response from server');
      }

      return PaymentResponse.fromJson(response);
    } catch (e) {
      print('Error creating payment: $e');
      throw Exception('Failed to create payment: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel> getPayment(int paymentId) async {
    try {
      final response = await _apiService.getRequest('/payment/$paymentId');

      if (response == null) {
        throw Exception('Payment not found');
      }

      return PaymentModel.fromJson(response);
    } catch (e) {
      print('Error getting payment: $e');
      throw Exception('Failed to get payment: $e');
    }
  }

  // Get all payments
  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final response = await _apiService.getRequest('/payment');

      if (response == null) {
        return [];
      }

      final List<dynamic> paymentsJson = response as List<dynamic>;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting payments: $e');
      throw Exception('Failed to get payments: $e');
    }
  }

  // Start Midtrans payment process (simplified for now)
  Future<dynamic> startPayment({
    required String snapToken,
  }) async {
    try {
      // For now, simulate payment process
      // In real implementation, this would use Midtrans SDK

      // Simulate processing time
      await Future.delayed(Duration(seconds: 2));

      // Return mock successful result
      return {
        'transactionStatus': 'success',
        'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
        'grossAmount': '100000.00'
      };
    } catch (e) {
      print('Error starting payment: $e');
      throw Exception('Failed to start payment: $e');
    }
  }

  // Handle payment result (simplified)
  PaymentStatus handlePaymentResult(dynamic result) {
    if (result == null) return PaymentStatus.failed;

    final status = result['transactionStatus']?.toString() ?? '';

    switch (status.toLowerCase()) {
      case 'success':
      case 'settlement':
        return PaymentStatus.success;
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'cancel':
        return PaymentStatus.cancelled;
      case 'expired':
        return PaymentStatus.expired;
      default:
        return PaymentStatus.pending;
    }
  }

  // Check payment status from backend
  Future<PaymentStatus> checkPaymentStatus(int paymentId) async {
    try {
      final payment = await getPayment(paymentId);
      return PaymentStatusExtension.fromString(payment.status) ??
          PaymentStatus.pending;
    } catch (e) {
      print('Error checking payment status: $e');
      return PaymentStatus.pending;
    }
  }

  // Complete payment (for testing purposes)
  Future<void> completePayment(int paymentId) async {
    try {
      await _apiService.postRequest('/payment/$paymentId/complete', {});
    } catch (e) {
      print('Error completing payment: $e');
      throw Exception('Failed to complete payment: $e');
    }
  }

  // Delete payment
  Future<void> deletePayment(int paymentId) async {
    try {
      await _apiService.deleteRequest('/payment/$paymentId');
    } catch (e) {
      print('Error deleting payment: $e');
      throw Exception('Failed to delete payment: $e');
    }
  }
}
