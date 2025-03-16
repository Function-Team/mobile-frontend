import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchActivityPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

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
              },
            ),
          ),
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
            _buildActivityItem('Workshop', Icons.work),
            _buildActivityItem('Working Space', Icons.business),
            _buildActivityItem('Work-out Session', Icons.fitness_center),
            _buildActivityItem('World Culture Festival', Icons.festival),
            _buildActivityItem('Workstation Setup Event', Icons.computer),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Venues',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _buildVenueItem('WoW Hall', 'assets/images/wow_hall.png'),
            _buildVenueItem(
                'Surya Working Space', 'assets/images/surya_ws.png'),
            _buildVenueItem('Wonder Studio', 'assets/images/wonder_studio.png'),
            _buildVenueItem('The Workstation', 'assets/images/workstation.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      onTap: () {
        Get.back(result: title);
      },
    );
  }

  Widget _buildVenueItem(String title, String imagePath) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath),
      ),
      title: Text(title),
      onTap: () {
        Get.back(result: title);
      },
    );
  }
}
