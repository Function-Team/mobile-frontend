import 'package:function_mobile/common/models/user_model.dart';

class ReviewModel {
  final int id;
  final int bookingId;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final UserModel? user; // Data pengguna lengkap jika tersedia dari API

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
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
      'user': user?.toJson(),
    };
  }

  // Helper method untuk mendapatkan username
  String get username => user?.username ?? 'User $userId';
}