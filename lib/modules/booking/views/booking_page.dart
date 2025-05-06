import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.put(BookingController());
    final venue = Get.arguments;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('Booking',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
      ),
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300] ?? Colors.grey)),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //image
          NetworkImageWithLoader(
              borderRadius: BorderRadius.circular(6.0),
              imageUrl: (venue?.firstPictureUrl?.isNotEmpty ?? false)
                  ? venue!.firstPictureUrl!
                  : 'https://via.placeholder.com/400x150?text=No+Image+Available',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover),
          const SizedBox(height: 8.0),
          //name
          Text(venue?.name ?? 'Venue Name',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8.0),
          //Reviews & Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(
                ' ${venue?.rating?.toStringAsFixed(1) ?? '0'} (${venue?.ratingCount ?? 'No'} Reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 20,
          ),
          //Booking Details
          Text('Details', style: Theme.of(context).textTheme.headlineSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //TODO: Date
                  Text('15 - 20 April'),
                  //TODO: Capacity
                  Text('50 Attendees'),
                ],
              ),
              OutlineButton(
                textSize: '12',
                text: 'Change',
                onPressed: () {
                  bookingController.displayChangeDateBottomSheet(context);
                },
                width: 80,
                height: 40,
              )
            ],
          ),

          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 20,
          ),
          //Booking Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Price',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                      "IDR ${NumberFormat("#,##0", "id_ID").format(venue?.price ?? 200000)}",
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              OutlineButton(
                textSize: '12',
                text: 'Details',
                onPressed: () {
                  bookingController.displayDetailBottomSheet(context);
                },
                width: 80,
                height: 40,
              )
            ],
          ),
        ]),
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SecondaryButton(text: 'Continue', onPressed: () {}),
      ),
    );
  }
}
