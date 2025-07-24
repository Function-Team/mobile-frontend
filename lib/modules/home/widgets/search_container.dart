import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:get/get.dart';

class SearchContainer extends StatelessWidget {
  final VoidCallback? onTapSearch;

  const SearchContainer({
    super.key,
    this.onTapSearch,
  });

  Widget _buildSearchField({
    required BuildContext context,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required VoidCallback onTap,
    required RxString textValue, // Tambahkan parameter untuk variabel Rx
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Text(
                    textValue.value.isEmpty ? hintText : textValue.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textValue.value.isEmpty
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required TimeOfDay? time,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            time != null
                ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                : hintText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: time != null ? Colors.black87 : Colors.grey[600],
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchController = Get.find<SearchFilterController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Activity/Venue Search Field
          _buildSearchField(
            context: context,
            controller: searchController.activityController,
            icon: Icons.search,
            hintText: 'Cari tempat atau aktivitas',
            onTap: () => searchController.goToSearchActivity(),
            textValue: searchController.activityText, // Tambahkan variabel Rx
          ),

          const SizedBox(height: 12),

          // Location Search Field with improved UX
          _buildSearchField(
            context: context,
            controller: searchController.locationController,
            icon: Icons.location_on_outlined,
            hintText: 'Pilih kota',
            onTap: () => searchController.showCityPicker(),
            textValue: searchController.locationText, // Tambahkan variabel Rx
          ),

          const SizedBox(height: 12),

          // Enhanced Date Range Selection
          _buildSearchField(
            context: context,
            controller: searchController.dateController,
            icon: Icons.date_range_outlined,
            hintText: 'Pilih tanggal',
            onTap: () => searchController.selectDateRange(),
            textValue: searchController.dateText, // Tambahkan variabel Rx
          ),

          const SizedBox(height: 12),

          // Time Row - sudah menggunakan Obx, tidak perlu diubah
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildTimeField(
                      context: context,
                      time: searchController.startTime.value,
                      hintText: 'Jam mulai',
                      onTap: () => searchController.selectStartTime(),
                    )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => _buildTimeField(
                      context: context,
                      time: searchController.endTime.value,
                      hintText: 'Jam selesai',
                      onTap: () => searchController.selectEndTime(),
                    )),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Enhanced Capacity Field
          _buildSearchField(
            context: context,
            controller: searchController.capacityController,
            icon: Icons.people_outline,
            hintText: 'Kapasitas maksimal',
            onTap: () => searchController.showCapacityPicker(),
            textValue: searchController.capacityText, // Tambahkan variabel Rx
          ),

          const SizedBox(height: 16),

          // Button Row with Search and Reset
          Row(
            children: [
              // Reset Button
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  onPressed: () {
                    searchController.clearAllFilters();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Search Button
              Expanded(
                flex: 2,
                child: Obx(() => PrimaryButton(
                  text: 'Cari Tempat',
                  isLoading: searchController.isLoading.value,
                  onPressed: () {
                    searchController.performAdvancedSearch();
                    if (onTapSearch != null) onTapSearch!();
                  },
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
