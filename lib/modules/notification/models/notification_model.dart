import 'package:flutter/material.dart';

enum NotificationType {
  booking,
  payment,
  general,
  promotion,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.imageUrl,
    this.actionUrl,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.booking:
        return Icons.event_available;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.general:
        return Icons.info;
      case NotificationType.promotion:
        return Icons.local_offer;
    }
  }

  Color get typeColor {
    switch (type) {
      case NotificationType.booking:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.general:
        return Colors.grey;
      case NotificationType.promotion:
        return Colors.orange;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'data': data,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
    );
  }
}