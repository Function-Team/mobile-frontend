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
            hintText: LocalizationHelper.tr(LocaleKeys.search_searchHint),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(LocalizationHelper.tr(LocaleKeys.common_loading)),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizationHelper.tr(LocaleKeys.common_error),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  child:
                      Text(LocalizationHelper.tr(LocaleKeys.common_tryAgain)),
                ),
              ],
            ),
          );
        }

        if (controller.filteredActivities.isEmpty &&
            controller.filteredVenues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizationHelper.tr(LocaleKeys.search_noResultsFound),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocalizationHelper.tr(LocaleKeys.search_tryDifferentSearch),
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activities section
              if (controller.filteredActivities.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.search_category),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Column(
                  children: controller.filteredActivities
                      .map((activity) =>
                          _buildActivityItem(activity, controller))
                      .toList(),
                ),
              ],

              // Venues section
              if (controller.filteredVenues.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.venue_venues),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Column(
                  children: controller.filteredVenues
                      .map((venue) => _buildVenueItem(venue, controller))
                      .toList(),
                ),
              ],
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
      title: Text(
          activity.name ?? LocalizationHelper.tr(LocaleKeys.common_unknown)),
      subtitle: Text(LocalizationHelper.tr(LocaleKeys.search_category)),
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
      title: Text(venue.name ??
          LocalizationHelper.tr(LocaleKeys.location_unknownVenue)),
      subtitle: Text(
          venue.city?.name ?? LocalizationHelper.tr(LocaleKeys.common_unknown)),
      trailing: venue.price != null
          ? Text(
              'Rp ${venue.price!.toStringAsFixed(0)}/hr',
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      onTap: () => controller.onVenueSelected(venue),
    );
  }
}
