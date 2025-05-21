import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/widgets/booking_card.dart';
import 'package:get/get.dart';

class BookingsListPage extends GetView<BookingListController> {
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.bookings.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.refreshBookings(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Bookings yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.refreshBookings(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              primary: false,
              itemCount: controller.bookings.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return BookingCard(
                  bookingModel: controller.bookings[index],
                  onTap: () {
                    Get.toNamed(MyRoutes.bookingDetail,
                        arguments: controller.bookings[index].id);
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
