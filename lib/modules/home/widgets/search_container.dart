import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/modules/home/pages/capacity_selection_page.dart';
import 'package:function_mobile/modules/home/pages/date_selection_page.dart';
import 'package:function_mobile/modules/home/pages/search_activity_page.dart';
import 'package:function_mobile/modules/home/pages/search_location_page.dart';
import 'package:get/get.dart';

class SearchContainer extends StatelessWidget {
  final TextEditingController controllerActivity;
  final TextEditingController controllerLocation;
  final TextEditingController controllerCapacity;
  final TextEditingController controllerDate;

  const SearchContainer({
    super.key,
    required this.controllerActivity,
    required this.controllerLocation,
    required this.controllerCapacity,
    required this.controllerDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
          children: [
        // Activity/Venue Search Field
        InkWell(
          onTap: () {
            Get.to(() => SearchActivityPage());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Search Activity/Venue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),

        // Location Search Field
        InkWell(
          onTap: () {
            Get.to(() => SearchLocationPage());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Search Location',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),

        // Capacity Selection
        InkWell(
          onTap: () {
            Get.to(() => CapacitySelectionPage());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Choose Venue\'s Capacity',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),

        // Date Selection
        InkWell(
          onTap: () {
            Get.to(() => DateSelectionPage());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Choose Date & Time',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
        SecondaryButton(
          text: 'Search',
          onPressed: () {},
          width: double.infinity,
        ),
      ]
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: e,
                  ))
              .toList()),
    );
  }
}
