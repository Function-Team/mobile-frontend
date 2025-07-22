class PaymentModel {
  final int? id;
  final int bookingId;
  final String? status;
  final bool isComplete;
  final DateTime? createdAt;
  final double? amount;

  PaymentModel({
    this.id,
    required this.bookingId,
    this.status,
    this.isComplete = false,
    this.createdAt,
    this.amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      status: json['status'],
      isComplete: json['is_complete'] ?? false,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      amount: json['amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'status': status,
      'is_complete': isComplete,
      'created_at': createdAt?.toIso8601String(),
      'amount': amount,
    };
  }
}

class PaymentCreateRequest {
  final int bookingId;

  PaymentCreateRequest({required this.bookingId});

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
    };
  }
}

class PaymentResponse {
  final PaymentModel payment;
  final MidtransResponse midtrans;

  PaymentResponse({
    required this.payment,
    required this.midtrans,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      payment: PaymentModel.fromJson(json['database']),
      midtrans: MidtransResponse.fromJson(json['midtrans']),
    );
  }
}

class MidtransResponse {
  final String token;
  final String redirectUrl;

  MidtransResponse({
    required this.token,
    required this.redirectUrl,
  });

  factory MidtransResponse.fromJson(Map<String, dynamic> json) {
    return MidtransResponse(
      token: json['token'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
    );
  }
}

enum PaymentStatus {
  pending,
  success,
  failed,
  expired,
  cancelled,
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.success:
        return 'success';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.expired:
        return 'expired';
      case PaymentStatus.cancelled:
        return 'cancelled';
    }
  }

  static PaymentStatus? fromString(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'success':
      case 'settlement':
        return PaymentStatus.success;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'expired':
        return PaymentStatus.expired;
      case 'cancelled':
      case 'cancel':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}