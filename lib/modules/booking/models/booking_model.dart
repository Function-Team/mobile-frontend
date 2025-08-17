import 'package:flutter/material.dart';
import 'package:function_mobile/modules/reviews/models/review_model.dart';
import 'package:function_mobile/common/models/user_model.dart';
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
  final String? paymentStatus;
  final String? placeName;

  final bool? isCancelled;
  final String? cancelReason;
  final String? cancelledBy;

  // Guest information fields
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final int? guestCount;
  final String? specialRequest;

  // Computed status fields dari backend - menggantikan logika frontend
  final bool? isPaidFromBackend;
  final bool? isExpiredFromBackend;
  final String? bookingStatusFromBackend;
  final String? detailedStatusFromBackend;

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
    this.isCancelled,
    this.cancelReason,
    this.cancelledBy,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    this.guestCount,
    this.specialRequest,
    this.isPaidFromBackend,
    this.isExpiredFromBackend,
    this.bookingStatusFromBackend,
    this.detailedStatusFromBackend,
    this.place,
    this.user,
    this.reviews,
    this.payment,
  });

  BookingStatus get status {
    // Gunakan computed status dari backend jika tersedia
    if (bookingStatusFromBackend != null) {
      switch (bookingStatusFromBackend!.toLowerCase()) {
        case 'cancelled':
          return BookingStatus.cancelled;
        case 'expired':
          return BookingStatus.expired;
        case 'completed':
          return BookingStatus.completed;
        case 'confirmed':
          return BookingStatus.confirmed;
        case 'pending':
        default:
          return BookingStatus.pending;
      }
    }

    // Fallback ke logika lama jika backend belum menyediakan computed status
    // Priority 1: Check if explicitly cancelled
    if (isCancelled == true || isBookingCancelled) {
      return BookingStatus.cancelled;
    }

    // Priority 2: Check if paid and confirmed (completed)
    if (isConfirmed && isPaid) {
      return BookingStatus.completed;
    }

    // Priority 3: Check if expired - rely on backend status only
    // Backend handles all expiry logic including payment and booking time
    if (paymentStatus != null && paymentStatus!.toLowerCase() == 'expired') {
      return BookingStatus.expired;
    }
    if (payment != null && payment!.status.toLowerCase() == 'expired') {
      return BookingStatus.expired;
    }

    // Priority 4: Check if confirmed but not paid
    if (isConfirmed) {
      return BookingStatus.confirmed;
    }

    // Default to pending
    return BookingStatus.pending;
  }

  bool get isBookingCancelled {
    // Check explicit cancellation flag
    if (isCancelled == true) return true;

    // Check payment status indicators - align with backend PaymentStatusMapper
    final cancelledPaymentStatuses = ['cancelled', 'failed', 'deny', 'cancel'];
    if (paymentStatus != null &&
        cancelledPaymentStatuses.contains(paymentStatus!.toLowerCase())) {
      return true;
    }

    // Check payment object status
    if (payment != null &&
        cancelledPaymentStatuses.contains(payment!.status.toLowerCase())) {
      return true;
    }

    return false;
  }

  bool get isInCancelledSection {
    return status == BookingStatus.cancelled ||
        status == BookingStatus.expired ||
        isBookingCancelled;
  }

  // Helper to check if booking is paid - gunakan computed status dari backend
  bool get isPaid {
    // Gunakan computed status dari backend jika tersedia
    if (isPaidFromBackend != null) {
      return isPaidFromBackend!;
    }

    // Fallback ke logika lama jika backend belum menyediakan computed status
    // Valid paid statuses from backend: settlement, paid, success
    final validPaidStatuses = ['settlement', 'paid', 'success'];

    // Check payment_status field
    if (paymentStatus != null &&
        validPaidStatuses.contains(paymentStatus!.toLowerCase())) {
      return true;
    }

    // Check payment object status
    if (payment != null &&
        validPaidStatuses.contains(payment!.status.toLowerCase())) {
      return true;
    }

    return false;
  }

  String get statusDisplayName {
    // Gunakan detailed status dari backend jika tersedia
    if (detailedStatusFromBackend != null && detailedStatusFromBackend!.isNotEmpty) {
      return detailedStatusFromBackend!;
    }

    // Fallback ke logika lama
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

  String get detailedStatusDisplayName {
    // Gunakan detailed status dari backend jika tersedia
    if (detailedStatusFromBackend != null && detailedStatusFromBackend!.isNotEmpty) {
      return detailedStatusFromBackend!;
    }

    // Fallback ke logika lama
    if (isCancelled == true) {
      if (cancelledBy != null) {
        return cancelledBy == 'user'
            ? 'Cancelled by You'
            : 'Cancelled by Venue';
      }
      return 'Cancelled';
    }

    // Check payment status for detailed messages
    final currentPaymentStatus =
        paymentStatus?.toLowerCase() ?? payment?.status.toLowerCase();

    if (currentPaymentStatus == 'expired') {
      return 'Payment Expired';
    }

    if (currentPaymentStatus == 'failed' || currentPaymentStatus == 'deny') {
      return 'Payment Failed';
    }

    if (currentPaymentStatus == 'cancelled' ||
        currentPaymentStatus == 'cancel') {
      return 'Payment Cancelled';
    }

    return statusDisplayName;
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

  String get formattedCreatedAt {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(createdAt!);
  }

  String get createdAtDisplay {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 0) {
      return 'Dibuat ${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return 'Dibuat ${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return 'Dibuat ${difference.inMinutes} menit lalu';
    } else {
      return 'Baru dibuat';
    }
  }

  bool get isCompleted {
    return status == BookingStatus.completed;
  }

  bool get needsPayment {
    return isConfirmed && !isPaid && !isBookingCancelled;
  }

  String get paymentStatusDisplay {
    // Get current payment status
    final currentStatus = paymentStatus ?? payment?.status;

    if (currentStatus != null) {
      // Normalize status display for consistency
      switch (currentStatus.toLowerCase()) {
        case 'settlement':
        case 'paid':
        case 'success':
          return 'PAID';
        case 'expired':
          return 'EXPIRED';
        case 'failed':
        case 'deny':
          return 'FAILED';
        case 'cancelled':
        case 'cancel':
          return 'CANCELLED';
        case 'pending':
          return 'PENDING';
        default:
          return currentStatus.toUpperCase();
      }
    }

    return 'PENDING';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(startDateTime);
  }

  String get startTime {
    return DateFormat('HH:mm').format(startDateTime);
  }

  String get endTime {
    return DateFormat('HH:mm').format(endDateTime);
  }

  String get formattedTimeRange {
    return '$startTime - $endTime';
  }

  Duration get duration {
    return endDateTime.difference(startDateTime);
  }

  static DateTime parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is String) {
      try {
        DateTime parsedDateTime;

        if (value.contains('T')) {
          // Handle ISO 8601 format from API
          if (value.contains('Z') ||
              value.contains('+') ||
              value.contains('-')) {
            // This is already in UTC or has timezone info
            parsedDateTime = DateTime.parse(value);

            // Convert UTC to local time (Indonesia is UTC+7)
            if (value.contains('Z')) {
              // UTC time, convert to local
              parsedDateTime = parsedDateTime.add(Duration(hours: 7));
            }
          } else {
            // ISO format without timezone, treat as local
            parsedDateTime = DateTime.parse(value);
          }
        } else {
          // Other formats, parse as is
          parsedDateTime = DateTime.parse(value);
        }

        return parsedDateTime;
      } catch (e) {
        print('Error parsing datetime: $value, error: $e');
        return DateTime.now();
      }
    }

    if (value is DateTime) {
      // Return as-is if already DateTime object
      return value;
    }

    return DateTime.now();
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
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
      isCancelled: json['is_cancelled'] as bool?,
      cancelReason: json['cancel_reason'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      guestName: json['guest_name'] as String?,
      guestEmail: json['guest_email'] as String?,
      guestPhone: json['guest_phone'] as String?,
      guestCount: json['guest_count'] as int?,
      specialRequest: json['special_request'] as String?,
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
      // Parse computed status fields dari backend
      isPaidFromBackend: json['is_paid'] as bool?,
      isExpiredFromBackend: json['is_expired'] as bool?,
      bookingStatusFromBackend: json['booking_status'] as String?,
      detailedStatusFromBackend: json['detailed_status'] as String?,
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
      'amount': amount,
      'payment_status': paymentStatus,
      'place_name': placeName,
      'is_cancelled': isCancelled,
      'cancel_reason': cancelReason,
      'cancelled_by': cancelledBy,
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'guest_count': guestCount,
      'special_request': specialRequest,
      // Include computed status fields dari backend
      'is_paid': isPaidFromBackend,
      'is_expired': isExpiredFromBackend,
      'booking_status': bookingStatusFromBackend,
      'detailed_status': detailedStatusFromBackend,
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
    bool? isCancelled,
    String? cancelReason,
    String? cancelledBy,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    int? guestCount,
    String? specialRequest,
    VenueModel? place,
    UserModel? user,
    List<ReviewModel>? reviews,
    PaymentModel? payment,
    // Computed status fields dari backend
    bool? isPaidFromBackend,
    bool? isExpiredFromBackend,
    String? bookingStatusFromBackend,
    String? detailedStatusFromBackend,
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
      isCancelled: isCancelled ?? this.isCancelled,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      guestCount: guestCount ?? this.guestCount,
      specialRequest: specialRequest ?? this.specialRequest,
      place: place ?? this.place,
      user: user ?? this.user,
      reviews: reviews ?? this.reviews,
      payment: payment ?? this.payment,
      // Include computed status fields dari backend
      isPaidFromBackend: isPaidFromBackend ?? this.isPaidFromBackend,
      isExpiredFromBackend: isExpiredFromBackend ?? this.isExpiredFromBackend,
      bookingStatusFromBackend: bookingStatusFromBackend ?? this.bookingStatusFromBackend,
      detailedStatusFromBackend: detailedStatusFromBackend ?? this.detailedStatusFromBackend,
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
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'is_confirmed': false,
      'amount': totalPrice ?? 0.0,
      'guest_name': userName ?? '',
      'guest_email': userEmail,
      'guest_phone': userPhone ?? '',
      'guest_count': capacity,
      'special_request': specialRequests ?? '',
    };
  }

  factory BookingCreateRequest.fromVenueAndForm({
    required VenueModel venue,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int capacity,
    required String specialRequests,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) {
    // Pastikan menit selalu 0 atau 30
    final adjustedStartTime = TimeOfDay(
      hour: startTime.hour,
      minute: startTime.minute < 30 ? 0 : 30,
    );

    final adjustedEndTime = TimeOfDay(
      hour: endTime.hour,
      minute: endTime.minute < 30 ? 0 : 30,
    );

    final startDateTimeLocal = DateTime(
      date.year,
      date.month,
      date.day,
      adjustedStartTime.hour,
      adjustedStartTime.minute,
    );

    final endDateTimeLocal = DateTime(
      date.year,
      date.month,
      date.day,
      adjustedEndTime.hour,
      adjustedEndTime.minute,
    );

    // JANGAN konversi ke UTC, kirim sebagai local time
    final startDateTime = startDateTimeLocal;
    final endDateTime = endDateTimeLocal;

    // Validasi durasi minimum 1 jam
    final duration = endDateTime.difference(startDateTime);
    if (duration.inMinutes < 60) {
      throw Exception('Minimum booking duration is 1 hour');
    }

    final durationInHours = duration.inMinutes / 60.0;
    final totalPrice = (venue.price ?? 0) * durationInHours;

    return BookingCreateRequest(
      placeId: venue.id,
      userId: null,
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

class PaymentModel {
  final int id;
  final int bookingId;
  final int amount;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: json['amount'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
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
