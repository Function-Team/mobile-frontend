import 'package:flutter/material.dart';
import 'package:function_mobile/modules/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized once
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SplashScreenContent(),
    );
  }
}

class SplashScreenContent extends StatefulWidget {
  const SplashScreenContent({super.key});

  @override
  State<SplashScreenContent> createState() => _SplashScreenContentState();
}

class _SplashScreenContentState extends State<SplashScreenContent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _lottieController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  void _startAnimationSequence() {
    if (!mounted) return;

    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  void _onLottieAnimationLoaded(LottieComposition composition) {
    print('Animation loaded: ${composition.duration}');

    // Set Lottie controller duration to match composition
    _lottieController.duration = composition.duration;

    // Start Lottie animation
    _lottieController.forward();

    // Set up a listener to detect when animation completes
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          mounted &&
          !_animationCompleted) {
        print('Lottie animation fully completed');
        _animationCompleted = true;
        _notifyControllerAnimationComplete();
      }
    });

    // Also set up a fallback in case the animation status listener doesn't fire
    // This ensures the animation completion is always detected
    Future.delayed(composition.duration, () {
      if (mounted && !_animationCompleted) {
        print('Animation completion detected via fallback timer');
        _animationCompleted = true;
        _notifyControllerAnimationComplete();
      }
    });
  }

  void _notifyControllerAnimationComplete() {
    // Notify SplashController that animation is complete
    try {
      final splashController = Get.find<SplashController>();
      splashController.onAnimationComplete();
      print(
          'SplashScreen: Successfully notified controller of animation completion');
    } catch (e) {
      print('Error notifying splash controller: $e');

      // If we can't notify the controller normally, try a more robust approach
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            final splashController = Get.find<SplashController>();
            splashController.forceNavigation();
            print('SplashScreen: Used force navigation as fallback');
          } catch (e2) {
            print('Error in fallback navigation: $e2');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.8,
                    constraints: const BoxConstraints(
                      minHeight: 300,
                      maxHeight: 600,
                    ),
                    child: Transform.scale(
                      scale: 1.5,
                      child: Lottie.asset(
                        'assets/animations/splash_screen_icon.json',
                        controller: _lottieController,
                        fit: BoxFit.contain,
                        repeat: false,
                        animate: true,
                        onLoaded: _onLottieAnimationLoaded,
                        errorBuilder: (context, error, stackTrace) {
                          print('Lottie error: $error');

                          // If Lottie fails to load, set a timer to ensure navigation still happens
                          Future.delayed(const Duration(milliseconds: 3000),
                              () {
                            if (mounted && !_animationCompleted) {
                              _animationCompleted = true;
                              _notifyControllerAnimationComplete();
                              print(
                                  'SplashScreen: Triggered animation completion after Lottie error');
                            }
                          });

                          return _buildFallBackIcon(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildFallBackIcon(BuildContext context) {
  return Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    ),
    child: Icon(
      Icons.app_registration,
      size: 100,
      color: Theme.of(context).colorScheme.error,
    ),
  );
}
