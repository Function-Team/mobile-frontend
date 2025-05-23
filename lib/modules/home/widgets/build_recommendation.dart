import 'package:flutter/material.dart';
import 'package:function_mobile/modules/home/controllers/home_controller.dart';
import 'package:function_mobile/modules/home/widgets/venue_recommend_card.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildRecommendation(BuildContext context, HomeController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Recommendation',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 10),
      Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Show 3 skeleton items as a placeholder
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Skeletonizer(
                    child: VenueRecommendCard(
                      imageUrl: '',
                      venueName: 'Loading...',
                      location: 'Loading...',
                      capacity: 'Loading...',
                      price: 'Loading...',
                      rating: '0.0',
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              children: [
                Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => controller.refreshVenues(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                )
              ],
            ),
          );
        }

        if (controller.recommendedVenues.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No venues available at the moment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.recommendedVenues.length,
            itemBuilder: (context, index) {
              final venue = controller.recommendedVenues[index];
              return Padding(
                padding: const EdgeInsets.only(right: 0),
                child: VenueRecommendCard(
                  imageUrl: venue.firstPictureUrl ?? '',
                  venueName: venue.name ?? 'Unknown Venue',
                  location: venue.city?.name ??
                      (venue.address != null
                          ? venue.address!.split(',').last.trim()
                          : 'Unknown Location'),
                  capacity: '${venue.maxCapacity ?? 100} people',
                  price:
                      'Rp ${NumberFormat("#,##0", "id_ID").format(venue.price ?? 0)}',
                  rating: venue.rating?.toStringAsFixed(1) ?? '4.5',
                  onTap: () {
                    if (venue.id != null) {
                      controller.goToVenueDetails(venue);
                    } else {
                      Get.snackbar('Error', 'Cannot open venue details',
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    ],
  );
}
