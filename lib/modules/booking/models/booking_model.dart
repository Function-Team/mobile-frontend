import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:intl/intl.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
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
  final double? amount;
  final String? paymentStatus; // Direct payment_status from API
  final String? placeName; // Direct place_name from API

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
    this.amount,
    this.paymentStatus,
    this.placeName,
    this.place,
    this.user,
    this.reviews,
    this.payment,
  });

  // Computed properties
  BookingStatus get status {
    // Check if paid (either from payment object or payment_status field)
    if (isConfirmed && isPaid) {
      return BookingStatus.completed;
    }

    // Check if confirmed but not paid
    if (isConfirmed) {
      return BookingStatus.confirmed;
    }

    // Check if expired (end time passed and not confirmed)
    if (endDateTime.isBefore(DateTime.now()) && !isConfirmed) {
      return BookingStatus.expired;
    }

    // Default to pending
    return BookingStatus.pending;
  }

  // Helper to check if booking is paid
  bool get isPaid {
    // First check the direct payment_status field
    if (paymentStatus != null && paymentStatus!.toLowerCase() == 'success') {
      return true;
    }

    // Then check the payment object if it exists
    if (payment != null && payment!.status.toLowerCase() == 'success') {
      return true;
    }

    return false;
  }

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.completed:
        return 'Completed';
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
      case BookingStatus.completed:
        return Colors.green.shade700;
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

  bool get isCompleted {
    return status == BookingStatus.completed;
  }

  bool get needsPayment {
    return isConfirmed && !isPaid;
  }

  String get paymentStatusDisplay {
    // First check direct payment_status
    if (paymentStatus != null) {
      return paymentStatus!.toUpperCase();
    }

    // Then check payment object
    if (payment != null) {
      return payment!.status.toUpperCase();
    }

    return 'PENDING';
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

    // Parse dates
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    // Parse amount
    double? parseAmount(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return BookingModel(
      id: json['id'],
      placeId: json['place_id'],
      userId: json['user_id'],
      startDateTime: parseDateTime(json['start_datetime']),
      endDateTime: parseDateTime(json['end_datetime']),
      isConfirmed: json['is_confirmed'] ?? false,
      createdAt:
          json['created_at'] != null ? parseDateTime(json['created_at']) : null,
      amount: parseAmount(json['amount']),
      paymentStatus: json['payment_status'],
      placeName: json['place_name'],
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

  void debugPrintStatus() {
    print('=== BOOKING DEBUG #$id ===');
    print('Place: ${place?.name ?? placeId}');
    print('Is Confirmed: $isConfirmed');
    print('Payment Status Field: $paymentStatus');
    print('Payment Object: ${payment?.toJson()}');
    print('Is Paid (computed): $isPaid');
    print('Is Completed: ${isConfirmed && isPaid}');
    print('=======================');
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
      'amount': amount,
      'payment_status': paymentStatus,
      'place_name': placeName,
    };
  }

  // Create booking request for API
  Map<String, dynamic> toCreateRequest() {
    return {
      'place_id': placeId,
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'is_confirmed': false,
      'amount': amount,
    };
  }

  BookingModel copyWith({
    int? id,
    int? placeId,
    int? userId,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isConfirmed,
    DateTime? createdAt,
    double? amount,
    String? paymentStatus,
    String? placeName,
    VenueModel? place,
    UserModel? user,
    List<ReviewModel>? reviews,
    PaymentModel? payment,
  }) {
    return BookingModel(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      placeName: placeName ?? this.placeName,
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
      'start_datetime': startDateTime.toIso8601String().split('.')[0],
      'end_datetime': endDateTime.toIso8601String().split('.')[0],
      'is_confirmed': false,
      'capacity': capacity,
      'special_requests': specialRequests,
      'amount': totalPrice ?? 0.0,
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

class ReviewModel {
  final int id;
  final int bookingId;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
