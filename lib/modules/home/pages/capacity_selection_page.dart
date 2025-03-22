import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:get/get.dart';

class CapacitySelectionPage extends StatelessWidget {
  const CapacitySelectionPage({super.key});

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCapacityOption('1-10 People'),
            _buildCapacityOption('10-100 People'),
            _buildCapacityOption('100-200 People'),
            _buildCapacityOption('200+ People'),
          ],
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
