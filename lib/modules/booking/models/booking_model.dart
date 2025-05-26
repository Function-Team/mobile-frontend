import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:intl/intl.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  expired,
}

class BookingModel {
  final int id;
  final int placeId;
  final int userId;
  final String startTime; // "HH:MM:SS" format
  final String endTime; // "HH:MM:SS" format
  final DateTime date;
  final bool isConfirmed;
  final DateTime? createdAt;

  // Related models (populated from joins)
  final VenueModel? place;
  final UserModel? user;
  final List<ReviewModel>? reviews;
  final PaymentModel? payment;

  BookingModel({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.isConfirmed,
    this.createdAt,
    this.place,
    this.user,
    this.reviews,
    this.payment,
  });

  // Computed properties
  BookingStatus get status {
    if (isConfirmed) return BookingStatus.confirmed;

    // Check if booking is expired (past date + end time)
    final bookingEndDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(endTime.split(':')[0]),
      int.parse(endTime.split(':')[1]),
    );

    if (bookingEndDateTime.isBefore(DateTime.now())) {
      return BookingStatus.expired;
    }

    return BookingStatus.pending;
  }

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.expired:
        return Colors.grey;
    }
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedTimeRange {
    return '$startTime - $endTime';
  }

  Duration get duration {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end.difference(start);
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      placeId: json['place_id'],
      userId: json['user_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      date: DateTime.parse(json['date']),
      isConfirmed: json['is_confirmed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      place: json['place'] != null ? VenueModel.fromJson(json['place']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((review) => ReviewModel.fromJson(review))
              .toList()
          : null,
      payment: json['payment'] != null
          ? PaymentModel.fromJson(json['payment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'user_id': userId,
      'start_time': startTime,
      'end_time': endTime,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'is_confirmed': isConfirmed,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create booking request for API
  Map<String, dynamic> toCreateRequest() {
    return {
      'place_id': placeId,
      'start_time': startTime,
      'end_time': endTime,
      'date': date.toIso8601String().split('T')[0],
      'is_confirmed': false,
    };
  }

  BookingModel copyWith({
    int? id,
    int? placeId,
    int? userId,
    String? startTime,
    String? endTime,
    DateTime? date,
    bool? isConfirmed,
    DateTime? createdAt,
    VenueModel? place,
    UserModel? user,
    List<ReviewModel>? reviews,
    PaymentModel? payment,
  }) {
    return BookingModel(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
      place: place ?? this.place,
      user: user ?? this.user,
      reviews: reviews ?? this.reviews,
      payment: payment ?? this.payment,
    );
  }
}

// Supporting models that match your backend
class UserModel {
  final int id;
  final String username;
  final String? profilePictureUrl;
  final String? email;

  UserModel({
    required this.id,
    required this.username,
    this.profilePictureUrl,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      profilePictureUrl: json['profile_picture_url'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'email': email,
    };
  }
}

class PaymentModel {
  final int id;
  final int bookingId;
  final int amount;
  final DateTime createdAt;
  final String status;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.createdAt,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: json['amount'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

// Booking Create Request Model
// class BookingCreateRequest {
//   final int placeId;
//   final String startTime;
//   final String endTime;
//   final DateTime date;

//   BookingCreateRequest({
//     required this.placeId,
//     required this.startTime,
//     required this.endTime,
//     required this.date,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'place_id': placeId,
//       'start_time': startTime,
//       'end_time': endTime,
//       'date': date.toIso8601String().split('T')[0],
//       'is_confirmed': false,
//     };
//   }
// }

// Update untuk BookingCreateRequest di booking_model.dart

// Model untuk Mobile Booking Request ke Web Admin Laravel
class MobileBookingCreateRequest {
  final int placeId;
  final int userId;
  final String venueName;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int capacity;
  final String? notes;

  MobileBookingCreateRequest({
    required this.placeId,
    required this.userId,
    required this.venueName,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'user_id': userId,
      'venue_name': venueName,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'start_time': startTime,
      'end_time': endTime,
      'capacity': capacity,
      'notes': notes,
    };
  }
  // Factory method to create from venue and form data
  factory MobileBookingCreateRequest.fromVenueAndForm({
    required VenueModel venue,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int capacity,
    String? specialRequests,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) {
    // Format time for API
    final formattedStartTime = 
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final formattedEndTime = 
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return MobileBookingCreateRequest(
      placeId: venue.id!,
      userId: 1, // Default user ID for testing
      venueName: venue.name ?? 'Unknown Venue',
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      date: date,
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      capacity: capacity,
      notes: specialRequests,
    );
  }
}

// Keep existing BookingCreateRequest untuk FastAPI backend
class BookingCreateRequest {
  final int placeId;
  final String startTime;
  final String endTime;
  final DateTime date;

  BookingCreateRequest({
    required this.placeId,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'start_time': startTime,
      'end_time': endTime,
      'date': date.toIso8601String().split('T')[0],
      'is_confirmed': false,
    };
  }
}
