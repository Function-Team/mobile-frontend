import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/payment/controllers/payment_controller.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:lottie/lottie.dart';

class PaymentStatusPage extends StatelessWidget {
  final int paymentId;
  final PaymentStatus status;

  const PaymentStatusPage({
    Key? key,
    required this.paymentId,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusAnimation(status),
            const SizedBox(height: 32),
            _buildStatusInfo(context, status),
            const SizedBox(height: 48),
            _buildActionButtons(context, controller, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAnimation(PaymentStatus status) {
    String animationPath;
    Color backgroundColor;

    switch (status) {
      case PaymentStatus.success:
        animationPath = 'assets/animations/success.json';
        backgroundColor = Colors.green[50]!;
        break;
      case PaymentStatus.pending:
        animationPath = 'assets/animations/pending.json';
        backgroundColor = Colors.orange[50]!;
        break;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        animationPath = 'assets/animations/failed.json';
        backgroundColor = Colors.red[50]!;
        break;
      case PaymentStatus.expired:
        animationPath = 'assets/animations/expired.json';
        backgroundColor = Colors.grey[50]!;
        break;
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Lottie.asset(
          animationPath,
          width: 120,
          height: 120,
          repeat: status == PaymentStatus.pending,
        ),
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context, PaymentStatus status) {
    String title;
    String description;
    Color titleColor;

    switch (status) {
      case PaymentStatus.success:
        title = 'Payment Successful!';
        description =
            'Your booking has been confirmed. You will receive a confirmation email shortly.';
        titleColor = Colors.green;
        break;
      case PaymentStatus.pending:
        title = 'Payment Pending';
        description =
            'Your payment is being processed. We will notify you once it\'s completed.';
        titleColor = Colors.orange;
        break;
      case PaymentStatus.failed:
        title = 'Payment Failed';
        description =
            'Your payment could not be processed. Please try again or use a different payment method.';
        titleColor = Colors.red;
        break;
      case PaymentStatus.cancelled:
        title = 'Payment Cancelled';
        description =
            'Your payment has been cancelled. No charges have been made to your account.';
        titleColor = Colors.red;
        break;
      case PaymentStatus.expired:
        title = 'Payment Expired';
        description =
            'Your payment session has expired. Please start a new booking to continue.';
        titleColor = Colors.grey;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildPaymentDetails(),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildDetailRow('Payment ID', '#$paymentId'),
          const SizedBox(height: 8),
          _buildDetailRow('Status', _getStatusText(status)),
          const SizedBox(height: 8),
          _buildDetailRow('Date', _formatCurrentDate()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, PaymentController controller,
      PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return Column(
          children: [
            PrimaryButton(
              isLoading: controller.isLoading.value,
              text: 'View Booking Details',
              onPressed: () => Get.offAllNamed('/booking-detail'),
              width: double.infinity,
              leftIcon: Icons.receipt_long,
            ),
            const SizedBox(height: 12),
            OutlineButton(
              text: 'Back to Home',
              onPressed: () => Get.offAllNamed('/home'),
            ),
          ],
        );

      case PaymentStatus.pending:
        return Column(
          children: [
            PrimaryButton(
              isLoading: controller.isLoading.value,
              text: 'Check Status',
              onPressed: () => controller.refreshPaymentStatus(paymentId),
              width: double.infinity,
              leftIcon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            OutlineButton(
              text: 'Back to Home',
              onPressed: () => Get.offAllNamed('/home'),
            ),
          ],
        );

      case PaymentStatus.failed:
        return Column(
          children: [
            PrimaryButton(
              isLoading: controller.isLoading.value,
              text: 'Try Again',
              onPressed: () => controller.retryPayment(),
              width: double.infinity,
              leftIcon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            OutlineButton(
              text: 'Use Different Method',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text(
                'Back to Home',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );

      case PaymentStatus.cancelled:
      case PaymentStatus.expired:
        return Column(
          children: [
            PrimaryButton(
              isLoading: controller.isLoading.value,
              text: 'Start New Booking',
              onPressed: () => Get.offAllNamed('/venues'),
              width: double.infinity,
              leftIcon: Icons.add,
            ),
            const SizedBox(height: 12),
            OutlineButton(
              text: 'Back to Home',
              onPressed: () => Get.offAllNamed('/home'),
            ),
          ],
        );
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.expired:
        return 'Expired';
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
