import 'dart:async';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final RxInt countdownSeconds = 0.obs;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Restore email from storage if needed (for page refresh)
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    countdownSeconds.value = 120; // 2 minutes
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _refreshPage(authController),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => authController.goToSignup(),
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Sign Up',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Email icon with animation
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Check Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'We\'ve sent a verification link to',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Email display
                  GetBuilder<AuthController>(builder: (controller) {
                    final email = controller.emailSignUpController.text.trim();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        email.isNotEmpty ? email : 'your-email@example.com',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: email.isNotEmpty
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              fontStyle: email.isNotEmpty
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  Text(
                    'Please check your email and click the verification link to activate your account.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Primary action buttons
                  Column(
                    children: [
                      // Open Email App button - Fixed with proper URL launcher
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: PrimaryButton(
                          isLoading: false,
                          text: 'Open Email App',
                          onPressed: () => _openEmailInbox(context),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Resend button with countdown
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Obx(() {
                          final isLoading = authController.isLoading.value;
                          final countdown = countdownSeconds.value;
                          final canResend = countdown == 0 && !isLoading;

                          return SecondaryButton(
                            text: isLoading
                                ? 'Sending...'
                                : countdown > 0
                                    ? 'Resend in ${_formatCountdown(countdown)}'
                                    : 'Resend Email',
                            onPressed: canResend
                                ? () => _resendVerificationEmail(
                                    authController, context)
                                : null,
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child:
                              Divider(color: Colors.grey[300], thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                          child:
                              Divider(color: Colors.grey[300], thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Secondary action buttons
                  Column(
                    children: [
                      // Check verification status button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _checkVerificationStatus(authController, context),
                          icon: Icon(
                            Icons.verified_user_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            'I\'ve verified, continue',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Change email button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton.icon(
                          onPressed: () => authController.goToSignup(),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          label: Text(
                            'Change Email Address',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ));
  }

  // Pull-to-refresh functionality
  Future<void> _refreshPage(AuthController authController) async {
    try {
      // Check if email is available before checking verification status
      if (authController.emailSignUpController.text.trim().isEmpty) {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: LocalizationHelper.tr(LocaleKeys.errors_emailNotVerified),
            type: SnackbarType.warning,
            autoClear: true,
            enableDebounce: false,
          );
        }
        return;
      }

      // Only check verification status via API (no auto-login)
      try {
        final isVerified = await authController.checkEmailVerificationStatus();

        if (isVerified) {
          // Email is verified - clear signup data and redirect to login
          await authController.clearSignupForm();

          if (mounted) {
            CustomSnackbar.show(
              context: context,
              message:
                  'Email verified successfully! Please login with your credentials.',
              type: SnackbarType.success,
              autoClear: true,
              enableDebounce: false,
            );
          }

          // Navigate to login page
          authController.goToLogin();
        } else {
          // Email not yet verified
          if (mounted) {
            CustomSnackbar.show(
              context: context,
              message:
                  'Email not yet verified. Please check your email and click the verification link.',
              type: SnackbarType.info,
              autoClear: true,
              enableDebounce: false,
            );
          }
        }
      } catch (e) {
        // If API check fails, show gentle message
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: LocalizationHelper.tr(LocaleKeys.common_error),
            type: SnackbarType.info,
            autoClear: true,
            enableDebounce: false,
          );
        }
      }
    } catch (e) {
      print('Error refreshing verification page: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to check verification status. Please try again.',
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false,
        );
      }
    }
  }

  Future<void> _openEmailInbox(BuildContext context) async {
    try {
      // Try web Gmail first (most reliable)
      final Uri webGmailUri =
          Uri.parse('https://mail.google.com/mail/u/0/#inbox');

      if (await canLaunchUrl(webGmailUri)) {
        await launchUrl(webGmailUri, mode: LaunchMode.externalApplication);

        CustomSnackbar.show(
          context: context,
          message: 'Opening Gmail to check your inbox...',
          type: SnackbarType.info,
          autoClear: true,
          enableDebounce: false,
        );
        return;
      }

      // Fallback to app-based approach
      _showEmailAppInstructions(context);
    } catch (e) {
      print('Error opening inbox: $e');
      _showEmailAppInstructions(context); // Fallback to current method
    }
  }

  void _showEmailAppInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.email_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          title: const Text(
            'Open Email App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please open your email app manually and look for the verification email:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildEmailAppItem('Gmail', Icons.email),
              _buildEmailAppItem('Outlook', Icons.mail_outline),
              _buildEmailAppItem('Apple Mail', Icons.mail),
              _buildEmailAppItem('Yahoo Mail', Icons.alternate_email),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Check your spam/junk folder if you don\'t see it.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailAppItem(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Enhanced resend with countdown timer
  void _resendVerificationEmail(
      AuthController authController, BuildContext context) async {
    try {
      // Check if email is available
      if (authController.emailSignUpController.text.trim().isEmpty) {
        CustomSnackbar.show(
          context: context,
          message: 'Please go back to signup to enter your email address.',
          type: SnackbarType.warning,
          autoClear: true,
          enableDebounce: false,
        );
        return;
      }

      await authController.resendVerificationEmail();

      // Start countdown timer
      _startCountdown();

      CustomSnackbar.show(
        context: context,
        message: LocalizationHelper.tr(LocaleKeys.auth_verifyEmail),
        type: SnackbarType.success,
        autoClear: true,
        enableDebounce: false,
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Handle specific error cases
      if (errorMessage.contains('already verified')) {
        CustomSnackbar.show(
          context: context,
          message: 'Email already verified! You can now login.',
          type: SnackbarType.success,
          autoClear: true,
          enableDebounce: false,
        );
        authController.goToLogin();
      } else if (errorMessage.contains('wait 2 minutes')) {
        _startCountdown(); // Start countdown even if server says wait
        CustomSnackbar.show(
          context: context,
          message: 'Please wait 2 minutes before requesting another email.',
          type: SnackbarType.warning,
          autoClear: true,
          enableDebounce: true,
        );
      } else if (errorMessage.contains('Email not found')) {
        CustomSnackbar.show(
          context: context,
          message: 'Email not found. Please check your email address.',
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false,
        );
      } else {
        CustomSnackbar.show(
          context: context,
          message: errorMessage.isNotEmpty
              ? errorMessage
              : 'Failed to resend email. Please try again.',
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false,
        );
      }
    }
  }

  // Check if user has been verified
  void _checkVerificationStatus(
      AuthController authController, BuildContext context) async {
    try {
      // Check if email is available
      if (authController.emailSignUpController.text.trim().isEmpty) {
        CustomSnackbar.show(
          context: context,
          message: 'Please go back to signup to enter your email address.',
          type: SnackbarType.warning,
          autoClear: true,
          enableDebounce: false,
        );
        return;
      }

      // Only check verification status via API (no auto-login)
      try {
        final isVerified = await authController.checkEmailVerificationStatus();

        if (isVerified) {
          // Clear stored signup data and redirect to login
          await authController.clearSignupForm();

          CustomSnackbar.show(
            context: context,
            message:
                'Email verified successfully! Please login with your credentials.',
            type: SnackbarType.success,
            autoClear: true,
            enableDebounce: false,
          );

          // Navigate to login page
          authController.goToLogin();
        } else {
          CustomSnackbar.show(
            context: context,
            message:
                'Email not yet verified. Please check your email and click the verification link.',
            type: SnackbarType.info,
            autoClear: true,
            enableDebounce: false,
          );
        }
      } catch (apiError) {
        // If API fails, suggest user try logging in
        CustomSnackbar.show(
          context: context,
          message: 'Unable to verify status. Please try again.',
          type: SnackbarType.info,
          autoClear: true,
          enableDebounce: false,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Unable to check verification status. Please try again.',
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false,
      );
    }
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
