import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:function_mobile/common/routes/routes.dart';

class ProfileController extends GetxController {
  // Get auth controller untuk akses user data
  final AuthController _authController = Get.find<AuthController>();
  
  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onReady() {
    super.onReady();
    // Listen to route changes to refresh when returning to profile page
    ever(_authController.user, (User? user) {
      if (user != null) {
        print('ProfileController: User data changed, refreshing profile');
      }
    });
  }

  void onResume() {
    refreshProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      
      // Refresh user data from API to get latest information
      await _authController.refreshUserData();
      
    } catch (e) {
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Failed to load user profile',
          type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk refresh data profile
  Future<void> refreshProfile() async {
    if (isRefreshing.value) return; // Prevent multiple simultaneous refreshes
    
    isRefreshing.value = true;
    try {
      print('ProfileController: Refreshing profile data...');
      
      // Refresh user data from API
      await _authController.refreshUserData();
      
      print('ProfileController: Profile data refreshed successfully');
    } catch (e) {
      print('ProfileController: Error refreshing profile: $e');
      // Show error message to user
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Failed to refresh profile data',
        type: SnackbarType.error,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Getter untuk akses mudah ke username dan email
  String get username => _authController.user.value?.username ?? 'Guest';
  String get email => _authController.user.value?.email ?? 'No Email';
  String? get profilePicture => null;

  Future<void> updateProfile({
    String? name,
    String? email,
    String? imageUrl,
  }) async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to update user profile
      await Future.delayed(Duration(seconds: 1));

      CustomSnackbar.show(
          context: Get.context!,
          message: 'Success to update profile',
          type: SnackbarType.success);
    } catch (e) {
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Failed to update profile',
          type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSettings() {
    Get.toNamed(MyRoutes.settings);
  }

  void navigateToEditProfile() {
    Get.toNamed(MyRoutes.editProfile);
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