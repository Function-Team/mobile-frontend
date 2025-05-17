import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

class FavoriteModel {
  final int id;
  final VenueModel venue;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.venue,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      venue: VenueModel.fromJson(json['venue']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue': venue.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}