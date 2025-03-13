import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateSelectionPage extends StatefulWidget {
  @override
  _DateSelectionPageState createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Date & Time'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Select Date'),
            subtitle: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('Start Time'),
            subtitle: Text(startTime.format(context)),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: startTime,
              );
              if (picked != null) {
                setState(() {
                  startTime = picked;
                });
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('End Time'),
            subtitle: Text(endTime.format(context)),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: endTime,
              );
              if (picked != null) {
                setState(() {
                  endTime = picked;
                });
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Get.back(result: {
              'date': selectedDate,
              'startTime': startTime,
              'endTime': endTime,
            });
          },
          child: Text('Continue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            minimumSize: Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }
}
