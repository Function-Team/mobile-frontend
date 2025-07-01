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
  final DateTime startDateTime;
  final DateTime endDateTime;
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
    required this.startDateTime,
    required this.endDateTime,
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

    if (endDateTime.isBefore(DateTime.now())) {
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
    return DateFormat('MMM dd, yyyy').format(startDateTime);
  }

  String get startTime {
    return "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}";
  }

  String get endTime {
    return "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }

  String get formattedTimeRange {
    return '$startTime - $endTime';
  }

  Duration get duration {
    return endDateTime.difference(startDateTime);
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    print('Booking JSON: $json');
    return BookingModel(
      id: json['id'],
      placeId: json['place_id'],
      userId: json['user_id'],
      startDateTime: json['start_datetime'] is String
          ? DateTime.parse(json['start_datetime'])
          : (json['start_datetime'] is DateTime
              ? json['start_datetime']
              : DateTime.now()),
      endDateTime: json['end_datetime'] is String
          ? DateTime.parse(json['end_datetime'])
          : (json['end_datetime'] is DateTime
              ? json['end_datetime']
              : DateTime.now()),
      isConfirmed: json['is_confirmed'] ?? false,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : (json['created_at'] is DateTime
              ? json['created_at']
              : null),
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
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'is_confirmed': isConfirmed,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create booking request for API
  Map<String, dynamic> toCreateRequest() {
    return {
      'place_id': placeId,
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
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
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
      place: place ?? this.place,
      user: user ?? this.user,
      reviews: reviews ?? this.reviews,
      payment: payment ?? this.payment,
    );
  }
}

class BookingCreateRequest {
  final int placeId;
  final int? userId;
  final String venueName;
  final String? userName;
  final String userEmail;
  final String? userPhone;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final DateTime date;
  final int capacity;
  final String? specialRequests;
  final double? totalPrice;

  BookingCreateRequest({
    required this.placeId,
    this.userId,
    required this.venueName,
    this.userName,
    required this.userEmail,
    this.userPhone,
    required this.startDateTime,
    required this.endDateTime,
    required this.date,
    required this.capacity,
    this.specialRequests,
    this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'user_id': userId ?? 1, // Default user ID untuk testing
      'venue_name': venueName,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'capacity': capacity,
      'special_requests': specialRequests,
      'total_price': totalPrice,
    };
  }

  // Factory method untuk create dari venue dan form data
  factory BookingCreateRequest.fromVenueAndForm({
    required VenueModel venue,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int capacity,
    String? specialRequests,
    String userName = "Test User",
    String userEmail = "test@example.com",
    String? userPhone,
  }) {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    // Calculate total price
    final durationInHours =
        endDateTime.difference(startDateTime).inMinutes / 60;
    final totalPrice = (venue.price ?? 0) * durationInHours;

    return BookingCreateRequest(
      placeId: venue.id!,
      userId: 1, // Default untuk testing
      venueName: venue.name ?? 'Unknown Venue',
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      date: date,
      capacity: capacity,
      specialRequests: specialRequests,
      totalPrice: totalPrice,
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
