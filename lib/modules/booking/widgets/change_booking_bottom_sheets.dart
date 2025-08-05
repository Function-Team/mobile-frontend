import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:get/get.dart';

class ChangeBookingBottomSheet extends StatelessWidget {
  const ChangeBookingBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Date & Capacity',
                style: Get.textTheme.headlineSmall,
              ),
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          _dateRangePicker(controller),
          const SizedBox(height: 16),
          _capacityDropdown(controller),
          const SizedBox(height: 24),
          PrimaryButton(
            isLoading: false,
            width: double.infinity,
            text: 'Save Date',
            onPressed: () {
              print(
                  'Saved: ${controller.selectedDate.value}, Capacity: ${controller.selectedCapacity.value}');
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _dateRangePicker(BookingController controller) {
    return Obx(() {
      final range = controller.selectedDate.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date Range', style: Get.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  range != null ? _formatDate(range) : 'Start Date',
                  style: Get.textTheme.bodyMedium,
                ),
                Text(
                  range != null ? _formatDate(range) : 'End Date',
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlineButton(
              width: double.infinity,
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: Get.context!,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  // initialDateRange: range,
                );
                // if (picked != null) {
                //   controller.setDateRange(picked);
                // }
              },
              icon: Icons.date_range,
              text: 'Change Date',
            ),
          ],
        ),
      );
    });
  }

  Widget _capacityDropdown(BookingController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Capacity', style: Get.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: controller.selectedCapacity.value,
              isExpanded: true,
              hint: const Text('Choose Capacity'),
              items: controller.capacityOptions.map((String capacity) {
                return DropdownMenuItem<String>(
                  value: capacity,
                  child: Text('$capacity Attendees'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.setCapacity(value);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
