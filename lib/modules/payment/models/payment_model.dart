import 'package:flutter/material.dart';

class PaymentModel {
  final int? id;
  final int bookingId;
  final double? amount;
  final String status;
  final DateTime? createdAt;

  PaymentModel({
    this.id,
    required this.bookingId,
    this.amount,
    required this.status,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: json['amount']?.toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    int? id,
    int? bookingId,
    double? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentCreateRequest {
  final int bookingId;
  final double? amount;

  PaymentCreateRequest({
    required this.bookingId,
    this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'amount': amount,
    };
  }
}

class PaymentUpdateRequest {
  final String? status;
  final double? amount;

  PaymentUpdateRequest({
    this.status,
    this.amount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (amount != null) data['amount'] = amount;
    return data;
  }
}

class PaymentResponse {
  final int? bookingId;
  final double? amount;
  final String? status;
  final String? createdAt;
  final String? snapToken;
  final double? baseAmount;
  final double? totalAmount;

  PaymentResponse({
    this.bookingId,
    this.amount,
    this.status,
    this.createdAt,
    this.snapToken,
    this.baseAmount,
    this.totalAmount,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'];
    return PaymentResponse(
      bookingId: payment['database']?['booking_id'],
      amount: (payment['database']?['amount'] as num?)?.toDouble(),
      status: payment['database']?['status'],
      createdAt: payment['database']?['created_at'],
      snapToken: payment['midtrans']?['token'],
      baseAmount:
          (payment['pricing_breakdown']?['base_amount'] as num?)?.toDouble(),
      totalAmount:
          (payment['pricing_breakdown']?['total_amount'] as num?)?.toDouble(),
    );
  }

  PaymentModel get paymentModel => PaymentModel(
        id: null,
        bookingId: bookingId ?? 0,
        amount: amount,
        status: status ?? 'pending',
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}

// Simple enum for payment status
enum PaymentStatus {
  pending,
  success,
  failed,
  expired,
  cancelled,
}

extension PaymentStatusExtension on PaymentStatus {
  static PaymentStatus? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'success':
      case 'settlement':
      case 'paid':
        return PaymentStatus.success;
      case 'failed':
      case 'deny':
      case 'cancel':
        return PaymentStatus.failed;
      case 'pending':
        return PaymentStatus.pending;
      case 'expired':
        return PaymentStatus.expired;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending; // Default to pending instead of null
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.success:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.expired:
        return Colors.grey;
    }
  }

  String get displayText {
    switch (this) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.expired:
        return 'Expired';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.success:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.expired:
        return Icons.schedule;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.pending:
        return Icons.pending;
    }
  }
}
