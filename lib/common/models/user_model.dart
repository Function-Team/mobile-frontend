class UserModel {
  final int? id;
  final String? username;
  final String? profilePictureUrl;
  final String? email;

  UserModel({
    this.id,
    this.username,
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

  UserModel copyWith({
    int? id,
    String? username,
    String? profilePictureUrl,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      email: email ?? this.email,
    );
  }
}