import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/inputs/primary_text_field.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/profile/controllers/edit_profile_controller.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final EditProfileController controller = Get.put(EditProfileController());

    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(context),
              const SizedBox(height: 32),

              // Form section
              _buildProfileForm(context, controller),
              const SizedBox(height: 24),

              // Password section
              _buildPasswordSection(context, controller),
              const SizedBox(height: 32),

              // Messages section
              _buildMessages(context, controller),

              // Save button
              _buildSaveButton(context, controller),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your account information below. You\'ll need to enter your current password to save changes.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(
      BuildContext context, EditProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        // Username field
        Obx(() => Column(
              children: [
                PrimaryTextField(
                  label: LocalizationHelper.tr(LocaleKeys.auth_username),
                  hintText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person_outline),
                  keyboardType: TextInputType.text,
                  controller: controller.usernameController,
                  onChanged: controller.validateUsernameField,
                ),
                if (controller.usernameError.value.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.usernameError.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ],
              ],
            )),
        const SizedBox(height: 20),

        // Email field
        Obx(() => Column(
              children: [
                PrimaryTextField(
                  label: LocalizationHelper.tr(LocaleKeys.auth_email),
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  controller: controller.emailController,
                  onChanged: controller.validateEmailField,
                  readOnly: true,
                  enabled: false,
                  fillColor: Colors.grey[
                      200], // Add light gray background to indicate read-only
                ),
                if (controller.emailError.value.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.emailError.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email cannot be changed. Please contact support if you need to update your email.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ],
            )),
      ],
    );
  }

  Widget _buildPasswordSection(
      BuildContext context, EditProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Verification',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your current password to confirm changes',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),

        // Current password field
        Obx(() => Column(
              children: [
                PrimaryTextField(
                  label: 'Current Password',
                  hintText: 'Enter your current password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: controller.obscurePassword.value,
                  controller: controller.currentPasswordController,
                  onChanged: controller.validatePasswordField,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
                if (controller.passwordError.value.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.passwordError.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ],
              ],
            )),
      ],
    );
  }

  Widget _buildMessages(
      BuildContext context, EditProfileController controller) {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.successMessage.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.successMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                ),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildSaveButton(
      BuildContext context, EditProfileController controller) {
    return Obx(() => SecondaryButton(
          text: controller.isLoading.value
              ? 'Saving...'
              : LocalizationHelper.tr(LocaleKeys.common_saveChange),
          width: double.infinity,
          onPressed: controller.isLoading.value ? null : controller.saveProfile,
        ));
  }
}
