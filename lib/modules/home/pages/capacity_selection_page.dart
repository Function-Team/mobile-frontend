import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CapacitySelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Venue\'s Capacity'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(child: Column(
        children: [
          _buildCapacityOption('1-10 People'),
          _buildCapacityOption('10-100 People'),
          _buildCapacityOption('100-200 People'),
          _buildCapacityOption('200+ People'),
        ],
      ),),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Get.back(),
          child: Text('Continue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            minimumSize: Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityOption(String capacity) {
    return ListTile(
      title: Text(capacity),
      trailing: Radio(
        value: capacity,
        groupValue: null,
        onChanged: (value) {
          Get.back(result: value);
        },
      ),
      onTap: () {
        Get.back(result: capacity);
      },
    );
  }
}
