import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/home/controllers/home_controller.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:function_mobile/modules/home/widgets/build_header.dart';
import 'package:function_mobile/modules/home/widgets/build_recommendation.dart';
import 'package:function_mobile/modules/home/widgets/search_container.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final HomeController homeController = Get.find();
    final SearchFilterController searchController = Get.find();

    // Set status bar to transparent with light icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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
                      MediaQuery.of(context).viewPadding.top + 16,
                      16,
                      16,
                    ),
                    child: Column(
                      children: [
                        buildHeader(
                          context,
                          profilePicture: null,
                          name: authController.username,
                          onTapProfile: () {
                            homeController.goToProfile();
                          },
                        ),
                        const SizedBox(height: 40),
                        SearchContainer(
                          controllerActivity:
                              searchController.activityController,
                          controllerLocation:
                              searchController.locationController,
                          controllerCapacity:
                              searchController.capacityController,
                          controllerDate: searchController.dateController,
                          onTapSearch: () {
                            searchController.goToSearchResults();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: buildRecommendation(context, homeController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
