import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';
import '../../controllers/venue_detail_controller.dart';
import '../../../../common/widgets/buttons/custom_text_button.dart';

class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final VenueDetailController controller = Get.find<VenueDetailController>();
    
    return Obx(() {
      if (controller.isLoadingFacilities.value) {
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (controller.facilities.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationHelper.tr(LocaleKeys.venue_facilities),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextButton(
                  text: LocalizationHelper.tr(LocaleKeys.common_seeMore),
                  onTap: () {
                    _showAllFacilities(context, controller.facilities);
                  },
                  icon: Icons.arrow_forward,
                  isrightIcon: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFacilitiesGrid(controller.facilities),
          ],
        ),
      );
    });
  }

  Widget _buildFacilitiesGrid(List facilities) {
    // Show only first 4 facilities in grid
    final displayFacilities = facilities.take(4).toList();
    
    return Column(
      children: [
        for (int i = 0; i < displayFacilities.length; i += 2)
          Row(
            children: [
              Expanded(
                child: i < displayFacilities.length
                    ? _buildFacilityItem(displayFacilities[i])
                    : const SizedBox(),
              ),
              Expanded(
                child: i + 1 < displayFacilities.length
                    ? _buildFacilityItem(displayFacilities[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFacilityItem(dynamic facility) {
    final VenueDetailController controller = Get.find<VenueDetailController>();
    final facilityName = facility.name ?? 'Unknown Facility';
    final isAvailable = facility.isAvailable ?? true;
    final icon = controller.facilityIcons[facilityName] ?? Icons.check_circle;
    
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              facilityName,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
    );
  }
  
  void _showAllFacilities(BuildContext context, List facilities) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Semua Fasilitas',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: facilities.length,
                itemBuilder: (context, index) {
                  return _buildFacilityItem(facilities[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
