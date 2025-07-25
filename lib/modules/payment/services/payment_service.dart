import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart'
    as payment;
import 'package:function_mobile/modules/payment/models/payment_model.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  // Create payment - Backend calculates everything
  Future<PaymentResponse> createPayment(int bookingId, {double? amount}) async {
    // Create payment and get Snap token
      try {
        final request = PaymentCreateRequest(
          bookingId: bookingId,
          amount: amount,
        );

        print(
            '[PaymentService] Creating payment with bookingId: $bookingId, amount: $amount');

        final response = await _apiService.postRequest(
          '/payment',
          request.toJson(),
        );

        print('[PaymentService] Payment creation response: $response');

        if (response == null) {
          throw Exception('Failed to create payment: No response from server');
        }

        return PaymentResponse.fromJson(response);
      } catch (e) {
        print('[PaymentService] Error creating payment: $e');
        throw Exception('Failed to create payment: $e');
      }
    }

    // Get payment by ID
    Future<payment.PaymentModel> getPayment(int paymentId) async {
      try {
        print('[PaymentService] Fetching payment with ID: $paymentId');

        final response = await _apiService.getRequest('/payment/$paymentId');

        print('[PaymentService] Payment data: $response');

        if (response == null) {
          throw Exception('Payment not found');
        }

        return payment.PaymentModel.fromJson(response);
      } catch (e) {
        print('[PaymentService] Failed to get payment: $e');
        throw Exception('Failed to get payment: $e');
      }
    }

    // Get all payments
    Future<List<payment.PaymentModel>> getAllPayments() async {
      try {
        final response = await _apiService.getRequest('/payment');

        if (response == null || response is! List) {
          return [];
        }

        return (response as List)
            .map((json) => payment.PaymentModel.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception('Failed to get payments: $e');
      }
    }

    // Start Midtrans payment process
    Future<Map<String, dynamic>?> startPayment(
        {required String snapToken}) async {
      try {
        print(
            '[PaymentService] Starting mock payment with snapToken: $snapToken');

        await Future.delayed(const Duration(seconds: 2));

        final result = {
          'transactionStatus': 'success',
          'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
          'grossAmount': '100000.00'
        };

        print('[PaymentService] Mock payment result: $result');

        return result;
      } catch (e) {
        print('[PaymentService] Failed to start payment: $e');
        throw Exception('Failed to start payment: $e');
      }
    }

    // Handle payment result from Midtrans
    payment.PaymentStatus handlePaymentResult(Map<String, dynamic>? result) {
      print('[PaymentService] Handling payment result: $result');

      if (result == null) return payment.PaymentStatus.failed;

      final status =
          result['transactionStatus']?.toString().toLowerCase() ?? '';
      print('[PaymentService] Parsed transactionStatus: $status');

      switch (status) {
        case 'success':
        case 'settlement':
          return payment.PaymentStatus.success;
        case 'pending':
          return payment.PaymentStatus.pending;
        case 'failed':
        case 'failure':
          return payment.PaymentStatus.failed;
        case 'cancelled':
        case 'cancel':
          return payment.PaymentStatus.cancelled;
        case 'expired':
          return payment.PaymentStatus.expired;
        default:
          return payment.PaymentStatus.pending;
      }
    }

    // Check payment status from backend
    Future<payment.PaymentStatus> checkPaymentStatus(int paymentId) async {
      try {
        final paymentModel = await getPayment(paymentId);
        return payment.PaymentStatusExtension.fromString(paymentModel.status) ??
            payment.PaymentStatus.pending;
      } catch (e) {
        return payment.PaymentStatus.pending;
      }
    }
  }

