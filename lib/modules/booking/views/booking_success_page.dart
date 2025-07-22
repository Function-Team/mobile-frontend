import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:lottie/lottie.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Booking Confirmed',
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
            // Success Animation
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Lottie.asset(
                  'assets/animations/success.json',
                  width: 120,
                  height: 120,
                  repeat: false,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Success Message
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your payment has been processed successfully.\nYou will receive a confirmation email shortly.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Success Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSuccessItem(
                    Icons.check_circle,
                    'Payment Completed',
                    'Your payment has been processed',
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildSuccessItem(
                    Icons.email_outlined,
                    'Confirmation Sent',
                    'Check your email for booking details',
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildSuccessItem(
                    Icons.calendar_month,
                    'Booking Secured',
                    'Your venue is reserved for the selected date',
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // Action Buttons
            Column(
              children: [
                PrimaryButton(
                  text: 'View Booking Details',
                  onPressed: () => Get.offAllNamed('/booking-detail'),
                  width: double.infinity,
                  leftIcon: Icons.receipt_long,
                ),
                const SizedBox(height: 12),
                OutlineButton(
                  text: 'Book Another Venue',
                  onPressed: () => Get.offAllNamed('/venues'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
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
              const SizedBox(height: 2),
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
    );
  }
}