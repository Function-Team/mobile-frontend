import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/payment/controllers/payment_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';

class PaymentPage extends StatelessWidget {
  final BookingModel booking;

  const PaymentPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());

    // Initialize payment when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentPayment.value == null) {
        controller.initializePayment(booking);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => _showExitConfirmation(context, controller),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        return _buildPaymentContent(context, controller);
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Preparing your payment...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PaymentController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Initialization Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              isLoading: false,
              text: 'Try Again',
              onPressed: () => controller.initializePayment(booking),
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            OutlineButton(
              text: 'Go Back',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentContent(
      BuildContext context, PaymentController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingInfo(),
          const SizedBox(height: 24),
          _buildPaymentSummary(controller),
          const SizedBox(height: 24),
          _buildPaymentMethods(),
          const SizedBox(height: 32),
          _buildPaymentActions(context, controller),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationHelper.tr(LocaleKeys.booking_bookingDetails),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, 'Venue',
              booking.place?.name ?? 'Unknown Venue'),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.calendar_today, 'Date', _formatDate(booking.startDateTime)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Time', _formatTimeRange()),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.people, 'Capacity',
              'Booking confirmed'), // Remove capacity display since it's not in model
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(PaymentController controller) {
    final amount = booking.place?.price?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Venue Price', 'Rp ${_formatCurrency(amount)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Service Fee', 'Rp ${_formatCurrency(0)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Tax', 'Rp ${_formatCurrency(0)}'),
          const Divider(height: 24),
          _buildPriceRow(
            'Total',
            'Rp ${_formatCurrency(amount)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.black87 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodItem(
            'Credit/Debit Card',
            'Visa, Mastercard, JCB',
            Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            'Bank Transfer',
            'All major banks supported',
            Icons.account_balance,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            'E-Wallet',
            'GoPay, OVO, DANA, ShopeePay',
            Icons.wallet,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            'Convenience Store',
            'Alfamart, Indomaret',
            Icons.store,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentActions(
      BuildContext context, PaymentController controller) {
    return Obx(() {
      return Column(
        children: [
          PrimaryButton(
            isLoading: controller.isPaymentProcessing.value,
            text: controller.isPaymentProcessing.value
                ? 'Processing Payment...'
                : 'Pay Now',
            onPressed: controller.isPaymentProcessing.value
                ? null
                : () => controller.startPaymentProcess(),
            width: double.infinity,
            leftIcon: controller.isPaymentProcessing.value
                ? Icons.hourglass_empty
                : Icons.payment,
          ),
          const SizedBox(height: 12),
          OutlineButton(
            text: 'Cancel Payment',
            onPressed: () => _showExitConfirmation(context, controller),
            textColor: Colors.red,
            outlineColor: Colors.red,
          ),
        ],
      );
    });
  }

  void _showExitConfirmation(
      BuildContext context, PaymentController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Payment?'),
          content: const Text(
            'Are you sure you want to cancel this payment? Your booking will not be confirmed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Payment'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.cancelPayment();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeRange() {
    final start = booking.startDateTime;
    final end = booking.endDateTime;

    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
