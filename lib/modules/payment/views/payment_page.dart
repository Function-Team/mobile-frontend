import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/payment/controllers/payment_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart'
    as payment;

class PaymentPage extends StatelessWidget {
  final BookingModel booking;

  const PaymentPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());

    // Initialize payment and start payment process when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentPayment.value == null) {
        _initializeAndStartPayment(controller);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          LocalizationHelper.tr(LocaleKeys.payment_payment),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            LocalizationHelper.tr(LocaleKeys.payment_preparingPayment),
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
            Text(
              LocalizationHelper.tr(
                  LocaleKeys.payment_paymentInitializationFailed),
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
              text: LocalizationHelper.tr(LocaleKeys.payment_tryAgain),
              onPressed: () => controller.initializePayment(booking),
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            OutlineButton(
              text: LocalizationHelper.tr(LocaleKeys.payment_goBack),
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
          const SizedBox(height: 16),
          _buildPaymentInfo(),
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
          _buildInfoRow(
              Icons.location_on,
              'Venue',
              booking.place?.name ??
                  LocalizationHelper.tr(LocaleKeys.location_unknownVenue)),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.calendar_today, 'Date', _formatDate(booking.startDateTime)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Time', _formatTimeRange()),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.people,
              'Capacity',
              LocalizationHelper.tr(LocaleKeys
                  .booking_status_confirmed)), // Remove capacity display since it's not in model
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
          Text(
            LocalizationHelper.tr(LocaleKeys.booking_paymentSummary),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(LocalizationHelper.tr(LocaleKeys.booking_venuePrice),
              'Rp ${_formatCurrency(amount)}'),
          const SizedBox(height: 8),
          _buildPriceRow(LocalizationHelper.tr(LocaleKeys.common_serviceFee),
              'Rp ${_formatCurrency(0)}'),
          const SizedBox(height: 8),
          _buildPriceRow(LocalizationHelper.tr(LocaleKeys.common_tax),
              'Rp ${_formatCurrency(0)}'),
          const Divider(height: 24),
          _buildPriceRow(
            LocalizationHelper.tr(LocaleKeys.common_total),
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
          Text(
            LocalizationHelper.tr(LocaleKeys.payment_paymentMethods),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodItem(
            LocalizationHelper.tr(LocaleKeys.payment_creditDebitCard),
            LocalizationHelper.tr(LocaleKeys.payment_creditCardSubtitle),
            Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            LocalizationHelper.tr(LocaleKeys.payment_bankTransfer),
            LocalizationHelper.tr(LocaleKeys.payment_bankTransferSubtitle),
            Icons.account_balance,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            LocalizationHelper.tr(LocaleKeys.payment_eWallet),
            LocalizationHelper.tr(LocaleKeys.payment_eWalletSubtitle),
            Icons.wallet,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            LocalizationHelper.tr(LocaleKeys.payment_convenienceStore),
            LocalizationHelper.tr(LocaleKeys.payment_convenienceStoreSubtitle),
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

  Future<void> _initializeAndStartPayment(PaymentController controller) async {
    // Initialize payment first
    final success = await controller.initializePayment(booking);

    if (success) {
      // Automatically start payment process (redirect to Midtrans)
      await Future.delayed(const Duration(milliseconds: 1000));
      final paymentSuccess = await controller.startPaymentProcess();

      if (!paymentSuccess) {
        // If payment failed, stay on this page to show retry option
        print('[PaymentPage] Payment process failed, showing retry option');
      }
    } else {
      // Handle initialization failure
      print('[PaymentPage] Payment initialization failed');
    }
  }

  Widget _buildPaymentActions(
      BuildContext context, PaymentController controller) {
    return Obx(() {
      return Column(
        children: [
          if (controller.paymentStatus.value == payment.PaymentStatus.failed ||
              controller.errorMessage.value.isNotEmpty) ...[
            PrimaryButton(
              isLoading: controller.isPaymentProcessing.value,
              text: LocalizationHelper.tr(LocaleKeys.payment_tryAgain),
              onPressed: controller.isPaymentProcessing.value
                  ? null
                  : () => controller.startPaymentProcess(),
              width: double.infinity,
              leftIcon: Icons.refresh,
            ),
            const SizedBox(height: 12),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pembayaran akan dialihkan ke halaman Midtrans secara otomatis.',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              isLoading: controller.isPaymentProcessing.value,
              text: controller.isPaymentProcessing.value
                  ? 'Membuka Midtrans...'
                  : 'Bayar Sekarang',
              onPressed: controller.isPaymentProcessing.value
                  ? null
                  : () => controller.startPaymentProcess(),
              width: double.infinity,
              leftIcon: controller.isPaymentProcessing.value
                  ? Icons.hourglass_empty
                  : Icons.payment,
            ),
            const SizedBox(height: 12),
          ],
          OutlineButton(
            text: LocalizationHelper.tr(LocaleKeys.booking_cancelPayment),
            onPressed: () => _showExitConfirmation(context, controller),
            textColor: Colors.red,
            outlineColor: Colors.red,
          ),
        ],
      );
    });
  }

  Widget _buildPaymentInfo() {
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
            'Informasi Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(Icons.security, 'Pembayaran aman dengan Midtrans'),
          const SizedBox(height: 8),
          _buildInfoItem(Icons.payment, 'Berbagai metode pembayaran tersedia'),
          const SizedBox(height: 8),
          _buildInfoItem(Icons.timer, 'Proses pembayaran real-time'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation(
      BuildContext context, PaymentController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              LocalizationHelper.tr(LocaleKeys.payment_cancelPaymentTitle)),
          content: Text(
            LocalizationHelper.tr(LocaleKeys.payment_cancelPaymentConfirm),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                  LocalizationHelper.tr(LocaleKeys.buttons_continuePayment)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.cancelPayment();
              },
              child: Text(
                LocalizationHelper.tr(LocaleKeys.common_cancel),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return LocalizationHelper.tr(LocaleKeys.common_unknown);
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
