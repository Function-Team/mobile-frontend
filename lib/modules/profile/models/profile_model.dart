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

  factory ProfileModel.fromAuthUser(dynamic authUser) {
    return ProfileModel(
      name: authUser?.username ?? 'Guest',
      email: authUser?.email ?? 'No Email',
      phoneNumber: null, // TODO: Add phone number to user model
      address: null, // TODO: Add address to user model  
      profilePicture: null, // TODO: Add profile picture to user model
    );
  }

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
