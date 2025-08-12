import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/profile/controllers/profile_controller.dart';
import 'package:function_mobile/modules/profile/widgets/build_profile_card.dart';
import 'package:function_mobile/modules/profile/widgets/build_profile_options.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => profileController.refreshProfile(),
            color: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            // Refresh button
                            Obx(() => IconButton(
                                  onPressed: profileController
                                          .isRefreshing.value
                                      ? null
                                      : () =>
                                          profileController.refreshProfile(),
                                  icon: profileController.isRefreshing.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                        ),
                                )),
                            IconButton(
                              onPressed: () =>
                                  profileController.navigateToSettings(),
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Profile Content
                    Expanded(
                      child: Obx(() {
                        return buildProfileCard(
                          context,
                          authController.user.value,
                          profileController.profile.value,
                          () => profileController.navigateToEditProfile(),
                          profileController,
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Profile Options
                    buildProfileOptions(context, profileController),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
