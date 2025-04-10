import 'package:flutter/material.dart';

class VenueModel {
  final int? id;
  final String? name;
  final String? address;
  final String? description;
  final String? firstPicture;
  final List<PictureModel>? pictures;
  final String? mapsUrl;
  final int? categoryId;
  final int? facilityId;
  final int? activityId;
  final int? cityId;
  final int? hostId;
  final String? rules;
  final List<RoomModel>? rooms;
  final HostModel? host;
  final CategoryModel? category;
  final CityModel? city;
  final double? rating;
  final int? reviewCount;
  final List<FacilityModel>? facilities;
  final List<ReviewModel>? reviews;
  final List<ScheduleModel>? schedules;
  final int? price;
  final int? maxCapacity;

  String? get firstPictureUrl => firstPicture != null
      ? 'http://backend.thefunction.id/api/img/$firstPicture'
      : (pictures != null &&
              pictures!.isNotEmpty &&
              pictures!.first.filename != null)
          ? 'http://backend.thefunction.id/api/img/${pictures!.first.filename}'
          : null;

  VenueModel({
    this.id,
    this.name,
    this.address,
    this.description,
    this.firstPicture,
    this.mapsUrl,
    this.categoryId,
    this.facilityId,
    this.activityId,
    this.cityId,
    this.hostId,
    this.rules,
    this.rooms,
    this.pictures,
    this.host,
    this.category,
    this.city,
    this.rating,
    this.reviewCount,
    this.facilities,
    this.reviews,
    this.schedules,
    this.price,
    this.maxCapacity,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      mapsUrl: json['maps_url'],
      categoryId: json['category_id'],
      facilityId: json['facility_id'],
      activityId: json['activity_id'],
      cityId: json['city_id'],
      hostId: json['host_id'],
      rules: json['rules'],
      rooms: (json['rooms'] as List<dynamic>?)
          ?.map((room) => RoomModel.fromJson(room))
          .toList(),
      firstPicture: json['first_picture'],
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((picture) => PictureModel.fromJson(picture))
          .toList(),
      host: json['host'] != null ? HostModel.fromJson(json['host']) : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'],
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((facility) => FacilityModel.fromJson(facility))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((review) => ReviewModel.fromJson(review))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((schedule) => ScheduleModel.fromJson(schedule))
          .toList(),
      price: json['price'],
      maxCapacity: json['max_capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'maps_url': mapsUrl,
      'category_id': categoryId,
      'facility_id': facilityId,
      'activity_id': activityId,
      'city_id': cityId,
      'host_id': hostId,
      'rules': rules,
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
  final int? id;
  final String? filename;
  final int? placeId;

  String? get imageUrl =>
      filename != null ? 'http://backend.thefunction.id/img/$filename' : null;

  PictureModel({
    this.id,
    this.filename,
    this.placeId,
  });

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
      id: json['id'],
      filename: json['filename'],
      placeId: json['place_id'],
    );
  }
}

class HostModel {
  final int? id;
  final int? userId;
  final String? bio;
  final UserModel? user;

  HostModel({
    this.id,
    this.userId,
    this.bio,
    this.user,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'],
      userId: json['user_id'],
      bio: json['bio'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bio': bio,
    };
  }
}

class UserModel {
  final int? id;
  final String? username;
  final String? profilePictureUrl;

  UserModel({
    this.id,
    this.username,
    this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture_url': profilePictureUrl,
    };
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

class ReviewModel {
  final int? id;
  final int? bookingId;
  final int? userId;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final UserModel? user;

  ReviewModel({
    this.id,
    this.bookingId,
    this.userId,
    this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
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
      'created_at': createdAt?.toIso8601String(),
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
