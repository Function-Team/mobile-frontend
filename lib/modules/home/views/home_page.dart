import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/home/controllers/home_controller.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:function_mobile/modules/home/widgets/search_container.dart';
import 'package:function_mobile/modules/home/widgets/venue_recommend_card.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchFilterController searchController =
        Get.put(SearchFilterController());
    final AuthController authController = Get.find();
    final HomeController homeController = Get.put(HomeController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
                  child: Column(
                    children: [
                      _buildHeader(context, '', authController.username),
                      SizedBox(height: 40),
                      SearchContainer(
                        controllerActivity: searchController.activityController,
                        controllerLocation: searchController.locationController,
                        controllerCapacity: searchController.capacityController,
                        controllerDate: searchController.dateController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRecommendation(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String? profilePicture, String name) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[400],
                  child: profilePicture != null && profilePicture.isNotEmpty
                      ? ClipOval(
                          child: NetworkImageWithLoader(
                            imageUrl: profilePicture,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.grey[300]),
                    ),
                    Text(
                      name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(Icons.notifications,
                color: Theme.of(context).colorScheme.onPrimary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommendation',
              style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 10),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.recommendedVenues.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No venues available at the moment',
                    style: Theme.of(context).textTheme.bodyLarge,
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
                  print('Building venue item $index');
                  final venue = controller.recommendedVenues[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: VenueRecommendCard(
                      imageUrl: venue.firstPictureUrl ??
                          'https://via.placeholder.com/150',
                      venueName: venue.name ?? 'Unknown Venue',
                      location: venue.city?.name ??
                          venue.address?.split(',').last.trim() ??
                          'Unknown Location',
                      capacity: '${venue.maxCapacity ?? 100} people',
                      price:
                          'Rp ${NumberFormat("#,##0", "id_ID").format(venue.price ?? 0)}',
                      rating: '${venue.rating?.toStringAsFixed(1) ?? '4.5'}',
                      onTap: () {
                        if (venue.id != null) {
                          Get.toNamed('/detailVenue',
                              arguments: {'venueId': venue.id});
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
