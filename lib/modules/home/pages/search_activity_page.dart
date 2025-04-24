import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchActivityPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final RxList<String> filteredActivities = [
    'Workshop',
    'Working Space',
    'Work-out Session',
    'World Culture Festival',
    'Workstation Setup Event'
  ].obs;

  final RxList<String> filteredVenues = [
    'WoW Hall',
    'Surya Working Space',
    'Wonder Studio',
    'The Workstation'
  ].obs;

  SearchActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search Activity/Venue',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                searchController.clear();
                _filterItems(''); 
              },
            ),
          ),
          onChanged: _filterItems,
          // Handle when the user presses Enter/Submit
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              try {
                // Return the search query and type to the parent page
                Get.back(result: {'searchQuery': value, 'type': 'search'});
              } catch (e) {
                print('Error navigating back $e');
                Get.back();
              }
            }
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Activities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Obx(() => Column(
                  children: filteredActivities
                      .map((activity) =>
                          _buildActivityItem(activity, Icons.work))
                      .toList(),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Venues',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Obx(() => Column(
                  children: filteredVenues
                      .map((venue) => _buildVenueItem(venue, ''))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      // Reset to full list
      filteredActivities.assignAll([
        'Workshop',
        'Working Space',
        'Work-out Session',
        'World Culture Festival',
        'Workstation Setup Event'
      ]);
      filteredVenues.assignAll([
        'WoW Hall',
        'Surya Working Space',
        'Wonder Studio',
        'The Workstation'
      ]);
    } else {
      // Filter based on query
      final lowercaseQuery = query.toLowerCase();

      filteredActivities.assignAll([
        'Workshop',
        'Working Space',
        'Work-out Session',
        'World Culture Festival',
        'Workstation Setup Event'
      ].where((item) => item.toLowerCase().contains(lowercaseQuery)));

      filteredVenues.assignAll([
        'WoW Hall',
        'Surya Working Space',
        'Wonder Studio',
        'The Workstation'
      ].where((item) => item.toLowerCase().contains(lowercaseQuery)));
    }
  }

  Widget _buildActivityItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      onTap: () {
        Get.back(result: {'searchQuery': title, 'type': 'activity'});
      },
    );
  }

  Widget _buildVenueItem(String title, String imagePath) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imagePath.isNotEmpty ? AssetImage(imagePath) : null,
        child: imagePath.isEmpty ? Icon(Icons.place) : null,
      ),
      title: Text(title),
      onTap: () {
        // Return the selected venue to the parent page
        Get.back(result: {'searchQuery': title, 'type': 'venue'});
      },
    );
  }
}
