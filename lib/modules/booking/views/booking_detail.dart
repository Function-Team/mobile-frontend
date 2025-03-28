import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/modules/booking/widgets/booking_card.dart';

class BookingDetail extends StatelessWidget {
  const BookingDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Booking Detail'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Status Card
              Text(
                'Status',
                style: theme.textTheme.headlineSmall,
              ),
              BookingCard(
                  venueName: 'Real Space',
                  bookingID: 9909,
                  bookingDate: '12 Mar 2025',
                  bookingTime: '11:00-12:00',
                  bookingStatus: BookingStatus.confirmed,
                  price: 150000,
                  priceType: 'Rp'),
              const SizedBox(height: 20),
              // Booking Information
              //TODO: add Venue Details
              //TODO: add Venue Terms and Conditions
              Text(
                'Your Details',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              _buildYourInfoCard(
                  color: theme.colorScheme.tertiary,
                  textStyle: theme.textTheme.bodyMedium!),
              const SizedBox(height: 20),
              // Payment Information
              Text(
                'Price Details',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              _buildPriceDetails(theme.colorScheme.tertiary),
              const SizedBox(height: 30),
              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYourInfoCard(
      {required Color color, required TextStyle textStyle}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYourInfoRow('Name:', 'John Doe', textStyle),
            _buildYourInfoRow('Phone:', '+1 234 567 8900', textStyle),
            _buildYourInfoRow('Email:', 'john.doe@example.com', textStyle),
            _buildYourInfoRow('Location:', '123 Main St, City', textStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildYourInfoRow(String label, String value, TextStyle labelStyle) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: labelStyle.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPaymentRow('Service Fee', '\$120.00'),
            _buildPaymentRow('Tax', '\$10.00'),
            _buildPaymentRow('Discount', '-\$15.00'),
            const Divider(thickness: 0.5),
            _buildPaymentRow('Total', '\$115.00', isTotal: true),
            const SizedBox(height: 10),
            // Container(
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: Colors.green.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: const Row(
            //     children: [
            //       Icon(Icons.check_circle, color: Colors.green, size: 16),
            //       SizedBox(width: 8),
            //       Text(
            //         'Paid with Credit Card',
            //         style: TextStyle(color: Colors.green),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  //TODO: Add Summary Payment Method
  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Contact Venue Owner',
          onPressed: () {},
          leftIcon: Icons.chat,
          width: double.infinity,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            //TODO: Add Cancel Booking Functionality
            Expanded(
              child: OutlineButton(
                  text: 'Cancel Booking',
                  onPressed: () {},
                  textColor: Colors.red,
                  outlineColor: Colors.red),
            ),
            const SizedBox(width: 16),
            //TODO: Add Reschedule Functionality
            Expanded(
              child: OutlineButton(
                text: 'Reschedule',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
