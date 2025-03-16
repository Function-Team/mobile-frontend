import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchLocationPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search Location',
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
              ListTile(
                leading: Icon(Icons.my_location, color: Colors.blue),
                title: Text('Near my location'),
                onTap: () {
                  // Implement location detection
                  Get.back(result: 'Current Location');
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Regions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _buildLocationItem('Bekasi'),
              _buildLocationItem('Bogor'),
              _buildLocationItem('Jakarta'),
              _buildLocationItem('Surabaya'),
              _buildLocationItem('Semarang'),
            ],
          ),
        ));
  }

  Widget _buildLocationItem(String location) {
    return ListTile(
      leading: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
      title: Text(location),
      onTap: () {
        Get.back(result: location);
      },
    );
  }
}
