import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  // Get auth controller untuk akses user data
  final AuthController _authController = Get.find<AuthController>();
  
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
      
      // Simulate loading delay jika diperlukan
      await Future.delayed(Duration(milliseconds: 500));
      
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

  // Getter untuk akses mudah ke username dan email
  String get username => _authController.user.value?.username ?? 'Guest';
  String get email => _authController.user.value?.email ?? 'No Email';
  String? get profilePicture => null; // TODO: Add profile picture support

  Future<void> updateProfile({
    String? name,
    String? email,
    String? imageUrl,
  }) async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to update user profile
      await Future.delayed(Duration(seconds: 1));

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
    Get.toNamed('/settings');
  }

  void navigateToEditProfile() {
    Get.toNamed('/edit-profile');
  }

  void navigateToNotifications() {
    Get.toNamed('/notifications');
  }

  void navigateToPrivacy() {
    Get.toNamed('/privacy');
  }

  void navigateToHelp() {
    Get.toNamed('/help');
  }
}