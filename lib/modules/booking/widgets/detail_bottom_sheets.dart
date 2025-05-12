import 'package:flutter/material.dart';

class DetailBottomSheets extends StatelessWidget {
  const DetailBottomSheets({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Implement the booking details logic
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booking Details',
                  style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  icon: Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16.0),
          Text('Price Details',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Base Price', style: Theme.of(context).textTheme.bodyMedium),
              Text('\$100.00', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount', style: Theme.of(context).textTheme.bodyMedium),
              Text('-\$10.00', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taxes', style: Theme.of(context).textTheme.bodyMedium),
              Text('\$5.00', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('\$95.00',
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
