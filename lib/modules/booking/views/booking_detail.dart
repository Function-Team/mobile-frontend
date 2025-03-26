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
                style: theme.textTheme.displaySmall,
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
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              _buildYourInfoCard(theme.colorScheme.tertiary,
                  theme.colorScheme.primary, theme.textTheme.labelMedium!),
              const SizedBox(height: 20),
              // Payment Information
              Text(
                'Price Details',
                style: theme.textTheme.displaySmall,
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

  Widget _buildYourInfoCard(Color color, Color iconColor, TextStyle textStyle) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildYourInfoRow(
                Icons.person, 'Customer', 'John Doe', iconColor, textStyle),
            _buildYourInfoRow(
                Icons.phone, 'Phone', '+1 234 567 8900', iconColor, textStyle),
            _buildYourInfoRow(Icons.email, 'Email', 'john.doe@example.com',
                iconColor, textStyle),
            _buildYourInfoRow(Icons.location_on, 'Location',
                '123 Main St, City', iconColor, textStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildYourInfoRow(IconData icon, String label, String value,
      Color iconColor, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(label, style: textStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
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
            const Divider(thickness: 1),
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

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    return Row(
      children: [
        //TODO: Add Reschedule Functionality
        Expanded(
          child: OutlineButton(
            text: 'Reschedule',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        //TODO: Add Cancel Booking Functionality
        Expanded(
          child: PrimaryButton(
            text: 'Cancel Booking',
            onPressed: () {/* Handle cancel booking */},
          ),
        ),
      ],
    );
  }
}
