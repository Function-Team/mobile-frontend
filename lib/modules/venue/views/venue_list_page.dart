import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/controllers/venue_list_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/widgets/venue_card.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart'; // TAMBAHKAN

class VenueListPage extends GetView<VenueListController> {
  const VenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _buildSearchBar(context),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildSkeletonList();
          } else if (controller.hasError.value) {
            return _buildErrorState();
          } else {
            return Column(
              children: [
                _buildFilterSection(context),
                _buildVenueList(),
              ],
            );
          }
        }));
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 44,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText:
              LocalizationHelper.tr(LocaleKeys.search_searchVenueHint), // FIXED
          prefixIcon: Obx(() =>
              controller.isLoading.value && controller.searchQuery.isNotEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 15,
                        height: 15,
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
              : const SizedBox()),
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
                        LocalizationHelper.tr(
                            LocaleKeys.venue_allVenues),
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : Text(
                        '${controller.selectedCategory.value} ${LocalizationHelper.tr(LocaleKeys.venue_venues)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ],
          ),
          
          // Tampilkan parameter pencarian jika dari advanced search
          Obx(() => controller.isFromAdvancedSearch.value
              ? _buildSearchSummary(context)
              : const SizedBox.shrink()),
          
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

  // Widget baru untuk menampilkan parameter pencarian
  Widget _buildSearchSummary(BuildContext context) {
    return Obx(() {
      final summary = controller.searchSummary.value;
      if (summary.isEmpty) return const SizedBox.shrink();
      
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parameter Pencarian:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (summary['activity'] != null && summary['activity'].isNotEmpty)
              _buildSummaryItem(context, 'Aktivitas/Tempat', summary['activity']),
            if (summary['location'] != null && summary['location'].isNotEmpty)
              _buildSummaryItem(context, 'Lokasi', summary['location']),
            if (summary['date'] != null && summary['date'].isNotEmpty)
              _buildSummaryItem(context, 'Tanggal', summary['date']),
            if (summary['startTime'] != null && summary['endTime'] != null)
              _buildSummaryItem(context, 'Waktu', '${summary['startTime']} - ${summary['endTime']}'),
            if (summary['startTime'] != null)
              _buildSummaryItem(context, 'Waktu Mulai', summary['startTime']),
            if (summary['endTime'] != null)
              _buildSummaryItem(context, 'Waktu Selesai', summary['endTime']),
            if (summary['capacity'] != null && summary['capacity'].isNotEmpty)
              _buildSummaryItem(context, 'Kapasitas', summary['capacity']),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    return Obx(
      () {
        if (controller.hasError.value) {
          return _buildErrorState();
        }

        if (controller.venues.isEmpty) {
          return Expanded(
            child: _buildEmptyState(),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshVenues,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.venues.length,
              itemBuilder: (context, index) {
                final venue = controller.venues[index];
                return VenueCard(
                  venue: venue,
                  onTap: () {
                    controller.goToVenueDetails(venue);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return VenueCard(
            venue: VenueModel(),
            onTap: () {},
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
            child: Text(
                LocalizationHelper.tr(LocaleKeys.common_tryAgain)), // FIXED
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            LocalizationHelper.tr(LocaleKeys.search_noResultsFound), // FIXED
            style: const TextStyle(color: Colors.grey),
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
              LocalizationHelper.tr(
                  LocaleKeys.search_filterByCategory), // FIXED
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: Text(LocalizationHelper.tr(
                          LocaleKeys.search_allCategories)), // FIXED
                      backgroundColor: controller.selectedCategory.isEmpty
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1)
                          : null,
                      onPressed: () => controller.clearCategory(),
                    ),
                    ...controller.categories.map((category) => ActionChip(
                          label: Text(category),
                          backgroundColor:
                              controller.selectedCategory.value == category
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
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
                child: Text(
                    LocalizationHelper.tr(LocaleKeys.common_close)), // FIXED
              ),
            ),
          ],
        ),
      ),
    );
  }
}
