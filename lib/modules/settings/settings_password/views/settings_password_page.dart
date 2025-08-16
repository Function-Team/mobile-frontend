import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/inputs/primary_text_field.dart';
import 'package:get/get.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/settings/settings_password/controllers/settings_password_controller.dart';

class SettingsPasswordPage extends StatelessWidget {
  const SettingsPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsPasswordController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LocalizationHelper.tr(LocaleKeys.settings_changePassword),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                Text(
                  LocalizationHelper.tr(LocaleKeys.settings_changePassword),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your current password and choose a new password. We will send you an email to verify the change.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 40),

                // Current Password Field
                Obx(() => PrimaryTextField(
                      controller: controller.currentPasswordController,
                      label: 'Current Password',
                      hintText: 'Enter your current password',
                      prefixIcon: Icon(Icons.lock_outline),
                      obscureText: !controller.isCurrentPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isCurrentPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleCurrentPasswordVisibility,
                      ),
                      validator: controller.validateCurrentPassword,
                    )),
                const SizedBox(height: 20),

                // New Password Field
                Obx(() => PrimaryTextField(
                      controller: controller.newPasswordController,
                      label: 'New Password',
                      hintText: 'Enter your new password',
                      prefixIcon: Icon(Icons.lock_outline),
                      obscureText: !controller.isNewPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isNewPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleNewPasswordVisibility,
                      ),
                      validator: controller.validateNewPassword,
                    )),
                const SizedBox(height: 20),

                // Confirm Password Field
                Obx(() => PrimaryTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Confirm New Password',
                      hintText: 'Confirm your new password',
                      prefixIcon: Icon(Icons.lock_outline),
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                      validator: controller.validateConfirmPassword,
                    )),
                const SizedBox(height: 16),

                // Error Message
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Success Message
                Obx(() {
                  if (controller.successMessage.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.successMessage.value,
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Send Verification Email Button
                Obx(() => PrimaryButton(
                      width: 200,
                      text: 'Send Verification Email',
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.changePassword,
                      isLoading: controller.isLoading.value,
                    )),
                const SizedBox(height: 24),

                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement(context, 'At least 8 characters long'),
                      _buildRequirement(
                          context, 'Different from current password'),
                      _buildRequirement(
                          context, 'Must match confirmation password'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
