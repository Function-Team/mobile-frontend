import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart'
    as payment;
import 'package:function_mobile/modules/payment/models/payment_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

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

      return (response)
          .map((json) => payment.PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  // Get payment by booking ID
  Future<PaymentResponse> getPaymentByBookingId(int bookingId) async {
    try {
      print('[PaymentService] Fetching payment for booking ID: $bookingId');

      final response =
          await _apiService.getRequest('/payment/booking/$bookingId');

      print('[PaymentService] Payment data for booking: $response');

      if (response == null) {
        throw Exception('Payment not found for booking');
      }

      return PaymentResponse.fromJson({'payment': response});
    } catch (e) {
      print('[PaymentService] Failed to get payment by booking ID: $e');
      throw Exception('Failed to get payment by booking ID: $e');
    }
  }

  // Start Midtrans payment process
  Future<Map<String, dynamic>?> startPayment(
      {required String snapToken}) async {
    try {
      print('[PaymentService] Starting payment with snapToken: $snapToken');

      // Open Midtrans payment page in webview
      final result = await _openMidtransWebView(snapToken);
      print('[PaymentService] Payment result: $result');
      return result;
    } catch (e) {
      print('[PaymentService] Failed to start payment: $e');
      throw Exception('Failed to start payment: $e');
    }
  }

  // Open Midtrans payment page in webview
  Future<Map<String, dynamic>> _openMidtransWebView(String snapToken) async {
    final completer = Completer<Map<String, dynamic>>();

    // Create webview controller
    late final WebViewController controller;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('[PaymentService] Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('[PaymentService] Page finished loading: $url');

            // Check if this is a callback URL indicating payment completion
            if (url.contains('finish') ||
                url.contains('unfinish') ||
                url.contains('error')) {
              _handlePaymentCallback(url, completer);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('[PaymentService] Navigation request: ${request.url}');

            // Allow all navigation for Midtrans payment flow
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load Midtrans Snap payment page
    final snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
    controller.loadRequest(Uri.parse(snapUrl));

    // Show webview in a dialog or new page
    Get.to(() => Scaffold(
          appBar: AppBar(
            title: const Text('Pembayaran'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Get.back();
                if (!completer.isCompleted) {
                  completer.complete({
                    'transactionStatus': 'cancelled',
                    'orderId': '',
                    'grossAmount': '0'
                  });
                }
              },
            ),
          ),
          body: WebViewWidget(controller: controller),
        ));

    return completer.future;
  }

  // Handle payment callback from webview
  void _handlePaymentCallback(
      String url, Completer<Map<String, dynamic>> completer) {
    if (completer.isCompleted) return;

    Map<String, dynamic> result;

    if (url.contains('finish')) {
      // Payment successful
      result = {
        'transactionStatus': 'success',
        'orderId': _extractOrderId(url),
        'grossAmount': '0' // Will be updated from backend
      };
    } else if (url.contains('unfinish')) {
      // Payment pending or cancelled by user
      result = {
        'transactionStatus': 'pending',
        'orderId': _extractOrderId(url),
        'grossAmount': '0'
      };
    } else {
      // Payment failed
      result = {
        'transactionStatus': 'failed',
        'orderId': _extractOrderId(url),
        'grossAmount': '0'
      };
    }

    // Close webview and return result
    Get.back();
    completer.complete(result);
  }

  // Extract order ID from callback URL
  String _extractOrderId(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['order_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Handle payment result from Midtrans
  payment.PaymentStatus handlePaymentResult(Map<String, dynamic>? result) {
    print('[PaymentService] Handling payment result: $result');

    if (result == null) return payment.PaymentStatus.failed;

    final status = result['transactionStatus']?.toString().toLowerCase() ?? '';
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
