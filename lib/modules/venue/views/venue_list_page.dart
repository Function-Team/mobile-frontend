import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/controllers/venue_list_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/widgets/venue_card.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';

class VenueListPage extends GetView<VenueListController> {
  const VenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _buildSearchSummaryHeader(context),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
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

  // Widget baru untuk menampilkan parameter pencarian di header
  Widget _buildSearchSummaryHeader(BuildContext context) {
    return Obx(() {
      final summary = controller.searchSummary.value;
      final String locationText = summary['location'] ?? 'Semua Lokasi';
      final String venueCount = '${controller.venues.length} Properties';
      final String timeInfo = summary['timeInfo'] ?? '';
      final String capacityText = summary['capacity'] ?? '';

      return GestureDetector(
        onTap: () {}, // Kembali ke halaman pencarian
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$locationText ($venueCount)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (timeInfo.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      timeInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (capacityText.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    capacityText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
          ],
        ),
      );
    });
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
                        LocalizationHelper.tr(LocaleKeys.venue_allVenues),
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : Text(
                        '${controller.selectedCategory.value} ${LocalizationHelper.tr(LocaleKeys.venue_venues)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
              Row(
                children: [
                  // Tombol Filter
                  ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                    onPressed: () => _showFilterBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Sort
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Sort'),
                    onPressed: () {}, // Tambahkan fungsi sort di controller
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
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
            venue: VenueModel(id: 0),
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
