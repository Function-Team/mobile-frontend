import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/home/controllers/search_activity_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';

class SearchActivityPage extends StatelessWidget {
  const SearchActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchActivityController());

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: LocalizationHelper.tr(LocaleKeys.search_selectActivity),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.clearSearch,
            ),
          ),
          onChanged: controller.filterItems,
          onSubmitted: controller.onSearchSubmitted,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.search_selectActivity),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Activities section
              Column(
                children: controller.filteredActivities
                    .map((activity) => _buildActivityItem(activity, controller))
                    .toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Venues',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Venues section
              Column(
                children: controller.filteredVenues
                    .map((venue) => _buildVenueItem(venue, controller))
                    .toList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActivityItem(
      CategoryModel activity, SearchActivityController controller) {
    return ListTile(
      leading: Icon(Icons.work, color: Colors.grey[600]),
      title: Text(activity.name ?? 'Unknown Activity'),
      onTap: () => controller.onActivitySelected(activity),
    );
  }

  Widget _buildVenueItem(
      VenueModel venue, SearchActivityController controller) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            venue.firstPicture != null && venue.firstPicture!.isNotEmpty
                ? NetworkImage(venue.firstPicture!)
                : null,
        child: venue.firstPicture == null || venue.firstPicture!.isEmpty
            ? const Icon(Icons.place)
            : null,
      ),
      title: Text(venue.name ?? 'Unknown Venue'),
      subtitle: Text(venue.city?.name ?? ''),
      onTap: () => controller.onVenueSelected(venue),
    );
  }
}
