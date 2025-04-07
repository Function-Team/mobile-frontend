import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/widgets/booking_card.dart';

class BookingsListPage extends StatelessWidget {
  const BookingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        actions: [
          //TODO: Add History Page
          IconButton(
            icon: Icon(Icons.list_alt,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {},
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BookingCard(
                    venueName: 'Real Space',
                    bookingID: 09909,
                    bookingDate: '10 Mar 2022',
                    bookingTime: '12:00-14:00',
                    bookingStatus: BookingStatus.pending,
                    price: 0,
                    priceType: 'Rp',
                    timeRemaining: Duration(seconds: 30)),
                BookingCard(
                  venueName: 'Real Space',
                  bookingID: 09908,
                  bookingDate: '10 Mar 2022',
                  bookingTime: '12:00-14:00',
                  bookingStatus: BookingStatus.confirmed,
                  price: 0,
                  priceType: 'Rp',
                ),
                BookingCard(
                  venueName: 'Real Space',
                  bookingID: 09907,
                  bookingDate: '10 Mar 2022',
                  bookingTime: '12:00-14:00',
                  bookingStatus: BookingStatus.cancelled,
                  price: 0,
                  priceType: 'Rp',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
