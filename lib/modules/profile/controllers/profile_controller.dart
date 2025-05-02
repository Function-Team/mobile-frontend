import 'package:get/get.dart';

class User {
  final String name;
  final String email;
  final String imageUrl;
  final int posts;
  final int followers;
  final int following;

  User({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.posts,
    required this.followers,
    required this.following,
  });
}

class ProfileController extends GetxController {
  // Observable user data
  final Rx<User> _user = User(
    name: 'John Doe',
    email: 'john.doe@example.com',
    imageUrl: '',
    posts: 28,
    followers: 458,
    following: 269,
  ).obs;

  // Getter for user data
  User get user => _user.value;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to fetch user profile
      // For now, we're using dummy data initialized above
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? imageUrl,
  }) async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to update user profile
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      _user.update((user) {
        if (user != null) {
          user = User(
            name: name ?? user.name,
            email: email ?? user.email,
            imageUrl: imageUrl ?? user.imageUrl,
            posts: user.posts,
            followers: user.followers,
            following: user.following,
          );
        }
      });

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSettings() {
    // TODO: Implement navigation to settings page
    Get.toNamed('/settings');
  }

  void navigateToEditProfile() {
    // TODO: Implement navigation to edit profile page
    Get.toNamed('/edit-profile');
  }

  void navigateToNotifications() {
    // TODO: Implement navigation to notifications page
    Get.toNamed('/notifications');
  }

  void navigateToPrivacy() {
    // TODO: Implement navigation to privacy page
    Get.toNamed('/privacy');
  }

  void navigateToHelp() {
    // TODO: Implement navigation to help page
    Get.toNamed('/help');
  }
}
