import 'package:flutter/material.dart';

class TimeDisplayWidget extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final TimeOfDay? endTime;
  final bool isRangeMode;
  final DateTime? selectedDate;
  final bool showDuration;
  final Function(Duration)? formatDuration;

  const TimeDisplayWidget({
    super.key,
    required this.label,
    required this.selectedTime,
    this.endTime,
    this.isRangeMode = false,
    this.selectedDate,
    this.showDuration = false,
    this.formatDuration,
  });

  String _formatTime24Hour(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _hasValidTime() {
    if (isRangeMode) {
      return selectedTime != null && endTime != null;
    }
    return selectedTime != null;
  }

  String _getDisplayText() {
    if (isRangeMode) {
      if (selectedTime != null && endTime != null) {
        return '${_formatTime24Hour(selectedTime!)} - ${_formatTime24Hour(endTime!)}';
      } else if (selectedTime != null) {
        return '${_formatTime24Hour(selectedTime!)} - ?';
      } else {
        return 'Pilih rentang waktu';
      }
    } else {
      return selectedTime != null
          ? _formatTime24Hour(selectedTime!)
          : 'Pilih slot waktu terlebih dahulu';
    }
  }

  String _getHelpText() {
    if (isRangeMode) {
      if (selectedTime == null) {
        return 'Klik slot pertama untuk waktu mulai, lalu slot kedua untuk waktu akhir';
      } else if (endTime == null) {
        return 'Klik slot kedua untuk menentukan waktu akhir';
      }
    }
    return 'Waktu akan otomatis terisi saat Anda memilih slot waktu di atas';
  }

  Duration? _calculateDuration() {
    if (selectedDate == null || selectedTime == null || endTime == null) {
      return null;
    }

    final start = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final end = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    return end.difference(start);
  }

  Widget? _buildDurationDisplay() {
    if (!showDuration || !isRangeMode) return null;

    final duration = _calculateDuration();
    if (duration == null) return null;

    // Validate minimum duration
    if (duration < Duration(hours: 1)) {
      return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Minimum booking duration is 1 hour',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Validate maximum duration
    if (duration > Duration(days: 7)) {
      return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Maximum booking duration is 7 days',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Valid duration display
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Duration: ${formatDuration?.call(duration) ?? _defaultFormatDuration(duration)}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _defaultFormatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      if (hours > 0) {
        return '$days days $hours hours';
      } else {
        return '$days days';
      }
    } else {
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    }
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
              _getDisplayText(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _hasValidTime() ? Colors.black87 : Colors.grey[500],
              ),
            ),
            if (!_hasValidTime()) ...[
              SizedBox(height: 4),
              Text(
                _getHelpText(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (_buildDurationDisplay() != null) _buildDurationDisplay()!,
          ],
        ),
      ),
    );
  }
}
