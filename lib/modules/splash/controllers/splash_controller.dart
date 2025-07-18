import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final _isLoading = true.obs;
  final _hasNavigated = false.obs;
  final _animationCompleted = false.obs;
  final _autoCheckCompleted = false.obs;
  final _isUserLoggedIn = false.obs;

  late final AuthService _authService;
  late final ApiService _apiService;
  late final AuthController _authController;

  bool get isLoading => _isLoading.value;
  bool get hasNavigated => _hasNavigated.value;
  bool get animationCompleted => _animationCompleted.value;
  bool get autoCheckCompleted => _autoCheckCompleted.value;
  bool get isUserLoggedIn => _isUserLoggedIn.value;

  static const int _minSplashDuration = 3500;
  static const int _maxSplashDuration = 8000;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashSequence();
    });
  }

  void _initializeServices() {
    try {
      _authService = Get.find<AuthService>();
    } catch (e) {
      _authService = Get.put(AuthService());
    }

    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      _apiService = Get.put(ApiService());
    }

    try {
      _authController = Get.find<AuthController>();
    } catch (e) {
      _authController = Get.put(AuthController());
    }
  }

  void _startSplashSequence() {
    if (_hasNavigated.value) return;

    _performAppInitialization();
    Future.delayed(const Duration(milliseconds: _maxSplashDuration), () {
      if (!_hasNavigated.value) {
        print('SplashController: Timeout reached');
        _handleTimeout();
      }
    });
  }

  Future<void> _performAppInitialization() async {
    try {
      final startTime = DateTime.now();

      await _checkAuthenticationStatus();

      _isLoading.value = false;

      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
      final remainingTimeMs = _minSplashDuration - elapsedMs;

      if (remainingTimeMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingTimeMs));
      }

      _checkReadyToNavigate();
    } catch (e) {
      print('Initialization failed: $e');
      _handleInitializationError(e);
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final isLoggedIn =
          await _authController.checkLoginStatus(autoNavigate: false);
      _isUserLoggedIn.value = isLoggedIn;
      _autoCheckCompleted.value = true;
    } catch (e) {
      print('SplashController: Error checking authentication: $e');
      try {
        await _authService.clearAllUserData();
      } catch (clearError) {
        print('SplashController: Error clearing user data: $clearError');
      }
      _autoCheckCompleted.value = true;
    }
  }

  void onAnimationComplete() {
    _animationCompleted.value = true;
    _checkReadyToNavigate();
  }

  void _checkReadyToNavigate() {
    if (_animationCompleted.value &&
        _autoCheckCompleted.value &&
        !_hasNavigated.value) {

      _safeNavigateToNextScreen();
    } else {
      print(
          'SplashController: Waiting... Animation: ${_animationCompleted.value}}');
    } 
  }

  void _safeNavigateToNextScreen() {
    if (_hasNavigated.value) {
      return;
    }

    if (!Get.isRegistered<SplashController>()) {
      return;
    }

    _hasNavigated.value = true;

    Future.microtask(() async {
      try {
        String nextRoute;
        if (_isUserLoggedIn.value) {
          nextRoute = MyRoutes.bottomNav; //user is logged in
        } else {
          nextRoute = MyRoutes.login; // user is not logged in
        }

        if (Get.isRegistered<SplashController>()) {
          print('SplashController: Executing navigation to $nextRoute');
          Get.offAllNamed(nextRoute);
          print('SplashController: Navigation completed');
        }
      } catch (e) {
        print('SplashController: Error during navigation: $e');
        _fallbackNavigation();
      }
    });
  }

  void _fallbackNavigation() {
    if (!_hasNavigated.value && Get.isRegistered<SplashController>()) {
      _hasNavigated.value = true;

      Future.microtask(() {
        if (Get.isRegistered<SplashController>()) {
          Get.offAllNamed(MyRoutes.login);
        }
      });
    }
  }

  void _handleInitializationError(dynamic error) {
    if (_hasNavigated.value) return;

    Future.microtask(() async {
      try {
        await _authService.clearAllUserData();
      } catch (e) {
        print('SplashController: Error clearing user data: $e');
      }

      if (!_hasNavigated.value && Get.isRegistered<SplashController>()) {
        _hasNavigated.value = true;
        Get.offAllNamed(MyRoutes.login);

        Future.delayed(const Duration(seconds: 1), () {
          if (Get.isRegistered<SplashController>()) {
            Get.snackbar(
              'Initialization Error',
              'Please try restarting the app',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );
          }
        });
      }
    });
  }

  void _handleTimeout() {
    print('SplashController: Handling timeout');
    _isLoading.value = false;

    if (_hasNavigated.value) return;
    _animationCompleted.value = true;
    _autoCheckCompleted.value = true;
    _fallbackNavigation();

    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isRegistered<SplashController>()) {
        Get.snackbar(
          'Loading Timeout',
          'App took too long to initialize',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  @override
  void onClose() {
    print('SplashController: Disposing...');
    super.onClose();
  }

  // Manual navigation trigger (for debugging)
  void forceNavigation() {
    print('SplashController: Force navigation triggered');
    _animationCompleted.value = true;
    _autoCheckCompleted.value = true;
    _safeNavigateToNextScreen();
  }
}
