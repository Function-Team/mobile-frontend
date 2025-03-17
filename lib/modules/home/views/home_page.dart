import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final AuthController authController = Get.find();
    final HomeController homeController = Get.find();
    final SearchFilterController searchController = Get.find();

    // Set status bar to transparent with light icons
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => homeController.refreshVenues(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  // Gradient background container
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

                  // Content container with proper top padding
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.of(context).viewPadding.top +
                            16, // Add status bar height + padding
                        16,
                        16),
                    child: Column(
                      children: [
                        _buildHeader(context,
                            profilePicture: 'https://picsum.photos',
                            name: authController.username),
                        SizedBox(height: 40),
                        SearchContainer(
                          controllerActivity:
                              searchController.activityController,
                          controllerLocation:
                              searchController.locationController,
                          controllerCapacity:
                              searchController.capacityController,
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
                    _buildRecommendation(context, homeController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String name,
    String? profilePicture,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: Row(
            children: [
              profilePicture != null && profilePicture.isNotEmpty
                  ? NetworkImageWithLoader(
                      imageUrl: profilePicture,
                      width: 40,
                      height: 40,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[400],
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              SizedBox(width: 8),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.grey[300]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Flexible(
                      child: Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
    );
  }

  Widget _buildRecommendation(BuildContext context, HomeController controller) {
    return Column(
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

          if (controller.hasError.value) {
            return Center(
              child: Column(
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => controller.refreshVenues(),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                  )
                ],
              ),
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
                final venue = controller.recommendedVenues[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: VenueRecommendCard(
                    imageUrl: venue.firstPictureUrl ??
                        'https://via.placeholder.com/150',
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
                        Get.toNamed('/venueDetail',
                            arguments: {'venueId': venue.id});
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
}
