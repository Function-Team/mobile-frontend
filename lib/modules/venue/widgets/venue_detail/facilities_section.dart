import 'package:flutter/material.dart';

import '../../../../common/widgets/buttons/custom_text_button.dart';

class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Facilities',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextButton(
                text: 'See more',
                onTap: () {
                  print('See More Clicked');
                },
                icon: Icons.arrow_forward,
                isrightIcon: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFacilityItem(Icons.table_bar, 'Table', true),
                    _buildFacilityItem(Icons.speaker, 'Speaker', true),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFacilityItem(Icons.local_parking, 'Parking', true),
                    _buildFacilityItem(Icons.ac_unit, 'AC', true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String text, bool isAvailable) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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

}