import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';

class ConflictDialog extends StatelessWidget {
  final List<TimeSlot> availableSlots;
  final VenueModel venue;
  final Function(TimeSlot slot) onSlotSelected;

  const ConflictDialog({
    Key? key,
    required this.availableSlots,
    required this.venue,
    required this.onSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter slots to only include operating hours (8-22)
    final filteredSlots = _filterOperatingHourSlots(availableSlots);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.schedule, color: Colors.orange[700], size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waktu Tidak Tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Pilih waktu alternatif',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waktu yang dipilih sudah dibooking oleh orang lain.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (filteredSlots.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.green[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Waktu tersedia hari ini:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredSlots.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      final slot = filteredSlots[index];
                      return _buildAvailableSlotItem(slot);
                    },
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, color: Colors.red[600], size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Tidak Ada Slot Tersedia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Semua waktu hari ini sudah dibooking. Silakan pilih tanggal lain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
          child: Text('Tutup'),
        ),
        if (filteredSlots.isEmpty)
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              // Signal to parent to focus on date picker
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.calendar_today, size: 18),
            label: Text('Pilih Tanggal Lain'),
          ),
      ],
      actionsPadding: EdgeInsets.fromLTRB(16, 8, 16, 16),
    );
  }

  Widget _buildAvailableSlotItem(TimeSlot slot) {
    // Calculate 1-hour duration from start time
    final startParts = slot.start.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);

    // Calculate end time (1 hour later)
    final startTotalMinutes = startHour * 60 + startMinute;
    final endTotalMinutes = startTotalMinutes + 60; // Add 1 hour
    final endHour = (endTotalMinutes ~/ 60) % 24;
    final endMinute = endTotalMinutes % 60;

    // Format display time with 1-hour duration
    final startTimeDisplay =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final endTimeDisplay =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    final oneHourDisplay = '$startTimeDisplay - $endTimeDisplay';

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          // Time icon and info
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_time,
              color: Colors.green[600],
              size: 20,
            ),
          ),

          SizedBox(width: 12),

          // Time display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  oneHourDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Durasi: 1 jam',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),

          // Action button
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              onSlotSelected(slot); // Callback to controller
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 1,
            ),
            child: Text(
              'Pilih',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filter available slots to only include operating hours (8-22)
  List<TimeSlot> _filterOperatingHourSlots(List<TimeSlot> slots) {
    return slots.where((slot) {
      final startHour = int.parse(slot.start.split(':')[0]);
      final endHour = int.parse(slot.end.split(':')[0]);

      // Only include slots that start >= 8 and end <= 22
      return startHour >= 8 && endHour <= 22;
    }).toList();
  }
}