import 'package:flutter/material.dart';

class TimeDisplayWidget extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;

  const TimeDisplayWidget({
    Key? key,
    required this.label,
    required this.selectedTime,
  }) : super(key: key);

  String _formatTime24Hour(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors
              .grey[50], // Light grey background to indicate non-clickable
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              selectedTime != null
                  ? _formatTime24Hour(selectedTime!)
                  : 'Pilih slot waktu terlebih dahulu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selectedTime != null ? Colors.black87 : Colors.grey[500],
              ),
            ),
            if (selectedTime == null) ...[
              SizedBox(height: 4),
              Text(
                'Waktu akan otomatis terisi saat Anda memilih slot waktu di atas',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
