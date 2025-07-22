import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/inputs/primary_text_field.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Controllers untuk form
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    // Populate controllers dengan data existing
    if (authController.user.value != null) {
      usernameController.text = authController.user.value!.username;
      emailController.text = authController.user.value!.email;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => _buildProfilePicture(context,
                profilePicture: authController.user.value
                    ?.toString() // TODO: Add profile picture URL
                )),
            const SizedBox(height: 24),
            _buildProfileForm(
                usernameController, emailController, phoneController),
            const SizedBox(height: 30),
            SecondaryButton(
              text: LocalizationHelper.tr(LocaleKeys.common_saveChange),
              width: double.infinity,
              onPressed: () {
                // TODO: Implement save functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, {String? profilePicture}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            profilePicture != null && profilePicture.isNotEmpty
                ? ClipOval(
                    child: NetworkImageWithLoader(
                      imageUrl: profilePicture,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: () {}, // TODO: Implement image upload
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileForm(
      TextEditingController usernameController,
      TextEditingController emailController,
      TextEditingController phoneController) {
    return Column(
      children: [
        PrimaryTextField(
          label: LocalizationHelper.tr(LocaleKeys.auth_username),
          hintText: LocalizationHelper.tr(LocaleKeys.booking_enterFullName),
          prefixIcon: Icon(Icons.person),
          keyboardType: TextInputType.text,
          controller: usernameController,
        ),
        SizedBox(height: 16),
        PrimaryTextField(
          label: LocalizationHelper.tr(LocaleKeys.auth_email),
          hintText: LocalizationHelper.tr(LocaleKeys.booking_enterEmail),
          prefixIcon: Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
        ),
        SizedBox(height: 16),
        PrimaryTextField(
          label: LocalizationHelper.tr(LocaleKeys.auth_phoneNumber),
          hintText: LocalizationHelper.tr(LocaleKeys.booking_enterPhoneNumber),
          prefixIcon: Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          controller: phoneController,
        ),
      ],
    );
  }
}
