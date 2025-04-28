import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/venue/controllers/venue_list_controller.dart';
import 'package:function_mobile/modules/venue/widgets/venue_card.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class VenueListPage extends GetView<VenueListController> {
  const VenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(context),
            Expanded(
              child: _buildVenueList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 44,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search venue',
          prefixIcon: Obx(() =>
              controller.isLoading.value && controller.searchQuery.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    )
                  : const Icon(Icons.search)),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.searchController.clear();
                  },
                )
              : SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onSubmitted: (value) => controller.searchVenues(value),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => controller.selectedCategory.isEmpty
                    ? Text(
                        'All Venues',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : Text(
                        '${controller.selectedCategory.value} Venues',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ],
          ),
          Obx(
            () => controller.selectedCategory.isEmpty
                ? const SizedBox.shrink()
                : Chip(
                    label: Text(controller.selectedCategory.value),
                    deleteIcon: const Icon(Icons.clear, size: 18),
                    onDeleted: () => controller.clearCategory(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    return Obx(() {
      // if (controller.isLoading.value) {
      //   return _buildShimmer();
      // }

      if (controller.hasError.value) {
        return _buildErrorState();
      }

      if (controller.venues.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshVenues,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.venues.length,
          itemBuilder: (context, index) {
            final venue = controller.venues[index];
            return VenueCard(
              venueName: venue.name ?? 'Unknown Venue',
              location: venue.city?.name ??
                  venue.address?.split(',').last.trim() ??
                  'Unknown Locating',
              rating: venue.rating ?? 0,
              ratingCount: venue.reviewCount ?? 0,
              price: venue.price ?? 0,
              imageUrl: venue.firstPictureUrl ?? '',
              priceType: 'Rp',
              onTap: () {
                if (venue.id != null) {
                  Get.toNamed(MyRoutes.venueDetail,
                      arguments: {'venueId': venue.id});
                } else {
                  Get.snackbar('Error', 'Cannot view this venue details',
                      snackPosition: SnackPosition.TOP);
                }
              },
              roomType: venue.category?.name ?? 'Venue',
              capacityType: '${venue.maxCapacity ?? 100}',
            );
          },
        ),
      );
    });
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return VenueCard(
            venueName: 'Venue Name',
            location: 'Location',
            rating: 4.5,
            ratingCount: 100,
            price: 100000,
            imageUrl: '',
            priceType: 'Rp',
            onTap: () {},
            roomType: 'Room Type',
            capacityType: '100',
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshVenues,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No venues found',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('All'),
                  backgroundColor: controller.selectedCategory.isEmpty
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                  onPressed: () => controller.clearCategory(),
                ),
                ...controller.categories.map((category) => ActionChip(
                  label: Text(category),
                  backgroundColor: controller.selectedCategory.value == category
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                  onPressed: () {
                    controller.setCategory(category);
                    Get.back();
                  },
                )),
              ],
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
