import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:function_mobile/modules/home/widgets/search_container.dart';
import 'package:function_mobile/modules/home/widgets/venue_recommend_card.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchFilterController searchController =
        Get.put(SearchFilterController());
    final AuthController authController = Get.find();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                        // stops: [0.5, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
                    child: Positioned(
                      child: Column(
                        children: [
                          _buildHeader(context, '', 'John Doe'),
                          SizedBox(height: 40),
                          SearchContainer(
                              controllerActivity:
                                  searchController.activityController,
                              controllerLocation:
                                  searchController.locationController,
                              controllerCapacity:
                                  searchController.capacityController,
                              controllerDate: searchController.dateController),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRecommendation(context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1612830720303-4b3b3b3b3b3b',
                          venueName: 'The Grand Ballroom',
                          location: 'Jakarta',
                          capacity: '1000 people',
                          price: 'Rp 10.000.000',
                          rating: '4.5'),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String? profilePicture, String name) {
    return Container(
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ],
                  )
                ],
              )),
          Expanded(
              flex: 1,
              child: Icon(Icons.notifications,
                  color: Theme.of(context).colorScheme.onPrimary, size: 24)),
        ],
      ),
    );
  }

  Widget _buildRecommendation(
    BuildContext context, {
    required String imageUrl,
    required String venueName,
    required String location,
    required String capacity,
    required String price,
    required String rating,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommendation',
              style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 10),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return VenueRecommendCard(
                    imageUrl: imageUrl,
                    venueName: venueName,
                    location: location,
                    capacity: capacity,
                    price: price,
                    rating: rating);
              },
            ),
          ),
        ],
      ),
    );
  }
}
