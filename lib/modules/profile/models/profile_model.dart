class ProfileModel {
  String? name;
  String? email;
  String? phoneNumber;
  String? address;
  String? profilePicture;

  ProfileModel({
    this.name,
    this.email,
    this.phoneNumber,
    this.address,
    this.profilePicture,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePicture': profilePicture,
    };
  }
}
