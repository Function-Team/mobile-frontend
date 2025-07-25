import 'package:flutter/material.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart'
    as payment;

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
}

class PaymentCreateRequest {
  final int bookingId;
  final double? amount;

  PaymentCreateRequest({
    required this.bookingId,
    this.amount,
  });

  Map<String, dynamic> toJson() {
    final json = {'booking_id': bookingId};
    final amt = amount;
    if (amt != null) {
      json['amount'] = amt.toInt();
    }
    return json;
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

  payment.PaymentModel get paymentModel => payment.PaymentModel(
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
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'pending':
        return PaymentStatus.pending;
      default:
        return null;
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
      default:
        return Icons.pending;
    }
  }
}
