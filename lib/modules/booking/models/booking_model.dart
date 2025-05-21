import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  expired,
  other,
}

class BookingModel {
  final int id;
  final DateTimeRange dateRange;
  final BookingStatus status;
  final VenueModel venue;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.venue,
    required this.createdAt,
    required this.dateRange,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      venue: VenueModel.fromJson(json['venue']),
      createdAt: DateTime.parse(json['created_at']),
      dateRange: DateTimeRange(
        start: DateTime.parse(json['start_date']),
        end: DateTime.parse(json['end_date']),
      ),
      status: BookingStatus.values.firstWhere(
        (element) => element.toString() == json['status'],
        orElse: () => BookingStatus.other,
      ),
    );
  }
}
