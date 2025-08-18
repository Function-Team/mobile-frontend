import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionSummaryWidget extends StatelessWidget {
  /// The selected start time, or null if no selection
  final TimeOfDay? startTime;
  
  /// The selected end time, or null if only start time is selected
  final TimeOfDay? endTime;
  
  /// Callback when user taps the clear button
  final VoidCallback onClear;

  const SelectionSummaryWidget({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (startTime == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Get.theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Get.theme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildSelectionText(),
              style: TextStyle(
                color: Get.theme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (endTime == null)
            Text(
              'Pilih waktu selesai',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              color: Colors.grey[600],
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the selection text showing times and duration
  String _buildSelectionText() {
    final formattedStartTime = _formatTime(startTime!);
    
    if (endTime != null) {
      final formattedEndTime = _formatTime(endTime!);
      final duration = _calculateDuration();
      return '$formattedStartTime - $formattedEndTime ($duration)';
    } else {
      return '$formattedStartTime - ?';
    }
  }

  /// Calculates and formats the duration between start and end time
  String _calculateDuration() {
    if (startTime == null || endTime == null) return '';

    final duration = (endTime!.hour * 60 + endTime!.minute) - 
                    (startTime!.hour * 60 + startTime!.minute);
    
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final mins = duration % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${duration}m';
  }

  /// Formats TimeOfDay to HH:mm string
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}