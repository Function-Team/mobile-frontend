import 'package:flutter/material.dart';
import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:function_mobile/modules/reviews/models/review_model.dart';
import 'package:function_mobile/common/models/user_model.dart';

class VenueModel {
  final int id;
  final String? name;
  final String? address;
  final String? description;
  final String? firstPicture;
  final List<PictureModel>? pictures;
  final String? mapsUrl;
  final int? categoryId;
  final int? activityId;
  final List<int>? facilityIds;
  final List<int>? activityIds;
  final int? cityId;
  final int? hostId;
  final String? rules;
  final List<RoomModel>? rooms;
  final HostModel? host;
  final CategoryModel? category;
  final CityModel? city;
  final double? rating;
  final int? ratingCount;
  final List<FacilityModel>? facilities;
  final List<ActivityModel>? activities;
  final List<ReviewModel>? reviews;
  final List<ScheduleModel>? schedules;
  final int? price;
  final int? maxCapacity;
  final String? size; // Tambahkan field ini
  final bool? isAvailable; // Menambahkan field untuk ketersediaan venue

  String? _cachedFirstPictureUrl; // Tambahkan property cache

  String? get firstPictureUrl {
    // Return cached value if already calculated
    if (_cachedFirstPictureUrl != null) {
      return _cachedFirstPictureUrl;
    }

    // Existing logic
    if (firstPicture != null &&
        firstPicture!.isNotEmpty &&
        firstPicture != 'null') {
      _cachedFirstPictureUrl = '${AppConstants.baseUrl}/img/$firstPicture';
      return _cachedFirstPictureUrl;
    }

    if (pictures != null && pictures!.isNotEmpty) {
      final validPicture = pictures!.firstWhere(
        (pic) =>
            pic.filename != null &&
            pic.filename!.isNotEmpty &&
            pic.filename != 'null',
        orElse: () => PictureModel(),
      );
      if (validPicture.filename != null &&
          validPicture.filename!.isNotEmpty &&
          validPicture.filename != 'null') {
        _cachedFirstPictureUrl = validPicture.imageUrl;
        return _cachedFirstPictureUrl;
      }
    }
    return null;
  }

  VenueModel({
    required this.id,
    this.name,
    this.address,
    this.description,
    this.firstPicture,
    this.mapsUrl,
    this.categoryId,
    this.facilityIds,
    this.activityIds,
    this.cityId,
    this.hostId,
    this.rules,
    this.rooms,
    this.pictures,
    this.host,
    this.category,
    this.activityId,
    this.city,
    this.rating,
    this.ratingCount,
    this.facilities,
    this.activities,
    this.reviews,
    this.schedules,
    this.price,
    this.maxCapacity,
    this.size, // Tambahkan parameter ini
    this.isAvailable, // Tambahkan parameter ketersediaan
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      mapsUrl: json['maps_url'],
      categoryId: json['category_id'],
      // IDs arrays (backward compatibility)
      facilityIds: json['facility_ids'] != null
          ? List<int>.from(json['facility_ids'])
          : null,
      activityIds: json['activity_ids'] != null
          ? List<int>.from(json['activity_ids'])
          : null,
      cityId: json['city_id'],
      hostId: json['host_id'],
      rules: json['rules'],

      // Rooms
      rooms: (json['rooms'] as List<dynamic>?)
          ?.map((room) => RoomModel.fromJson(room))
          .toList(),

      // Pictures - Replace the existing line
      pictures: _parsePictures(json['pictures'], json['id']),

      // Relations
      host: json['host'] != null ? HostModel.fromJson(json['host']) : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,

      // Full facility and activity objects
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((facility) => FacilityModel.fromJson(facility))
          .toList(),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((activity) => ActivityModel.fromJson(activity))
          .toList(),

      // Other fields
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((review) => ReviewModel.fromJson(review))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((schedule) => ScheduleModel.fromJson(schedule))
          .toList(),
      price: json['price'],
      maxCapacity: json['max_capacity'],
      size: json['size'], // Tambahkan parsing ini
      isAvailable: json['is_available'] ?? true, // Parsing ketersediaan dengan default true
    );
  }

  static List<PictureModel>? _parsePictures(
      dynamic picturesData, int? placeId) {
    if (picturesData == null) return null;

    try {
      final picturesList = picturesData as List<dynamic>;

      return picturesList
          .map((item) {
            if (item is String) {
              return PictureModel(
                id: item,
                filename: item,
                placeId: placeId,
              );
            } else if (item is Map<String, dynamic>) {
              return PictureModel.fromJson(item);
            } else {
              print('⚠️ Unknown picture format: $item');
              return PictureModel(
                id: null,
                filename: null,
                placeId: placeId,
              );
            }
          })
          .where((picture) =>
              picture.filename != null &&
              picture.filename!.isNotEmpty &&
              picture.filename != 'null')
          .toList();
    } catch (e) {
      print('❌ Error parsing pictures: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'maps_url': mapsUrl,
      'category_id': categoryId,
      'facility_ids': facilityIds,
      'activity_ids': activityIds,
      'city_id': cityId,
      'host_id': hostId,
      'rules': rules,
      'is_available': isAvailable,
    };
  }
}

class RoomModel {
  final int? id;
  final String? name;
  final int? price;
  final String? description;
  final int? maxCapacity;
  final int? placeId;

  RoomModel({
    this.id,
    this.name,
    this.price,
    this.description,
    this.maxCapacity,
    this.placeId,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      maxCapacity: json['max_capacity'],
      placeId: json['place_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'max_capacity': maxCapacity,
      'place_id': placeId,
    };
  }
}

class PictureModel {
  final String? id;
  final String? filename;
  final int? placeId;

  PictureModel({
    this.id,
    this.filename,
    this.placeId,
  });

  String? get imageUrl {
    if (filename == null || filename!.isEmpty || filename == 'null') {
      return null;
    }
    final fullUrl = '${AppConstants.baseUrl}/img/$filename';
    return fullUrl;
  }

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
      id: json['id'],
      filename: json['filename'],
      placeId: json['place_id'],
    );
  }

  factory PictureModel.fromVenueData(String filename, int placeId) {
    return PictureModel(
      id: filename,
      filename: filename,
      placeId: placeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'place_id': placeId,
    };
  }
}

class HostModel {
  final int? id;
  final int? userId;
  final String? bio;
  final String? phone;
  final UserModel? user;

  HostModel({
    this.id,
    this.userId,
    this.bio,
    this.phone,
    this.user,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'],
      userId: json['user_id'],
      bio: json['bio'],
      phone: json['phone'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bio': bio,
      'phone': phone,
      'user': user?.toJson(),
    };
  }

  // Get host display name - prioritas: user.username > "Host"
  String get displayName {
    return user?.username ?? 'Host';
  }

  // Check if phone number is available
  bool get hasPhone {
    return phone != null && phone!.isNotEmpty;
  }

  String? get formattedPhone {
    if (!hasPhone) return null;

    // Indonesian phone number formatting
    final digits = phone!.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('62')) {
      return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 9)} ${digits.substring(9)}';
    } else if (digits.startsWith('0')) {
      return '+62 ${digits.substring(1, 4)} ${digits.substring(4, 8)} ${digits.substring(8)}';
    }

    return phone; // Return original if no formatting applied
  }
}



class CategoryModel {
  final int? id;
  final String? name;

  CategoryModel({
    this.id,
    this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CityModel {
  final int? id;
  final String? name;

  CityModel({
    this.id,
    this.name,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class FacilityModel {
  final int? id;
  final String? name;
  final bool? isAvailable;
  final IconData? icon;

  FacilityModel({
    this.id,
    this.name,
    this.isAvailable,
    this.icon,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'],
      name: json['name'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_available': isAvailable,
    };
  }
}

// NEW: ActivityModel for handling activity objects
class ActivityModel {
  final int? id;
  final String? name;

  ActivityModel({
    this.id,
    this.name,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ScheduleModel {
  final String? day;
  final String? openTime;
  final String? closeTime;
  final bool? isClosed;

  ScheduleModel({
    this.day,
    this.openTime,
    this.closeTime,
    this.isClosed,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      day: json['day'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'open_time': openTime,
      'close_time': closeTime,
      'is_closed': isClosed,
    };
  }
}

class RatingStatsModel {
  final double averageRating;
  final int totalReviews;

  RatingStatsModel({
    required this.averageRating,
    required this.totalReviews,
  });

  factory RatingStatsModel.fromJson(Map<String, dynamic> json) {
    return RatingStatsModel(
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}
