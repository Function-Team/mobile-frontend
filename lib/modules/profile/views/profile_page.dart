import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/profile/controllers/profile_controller.dart';
import 'package:function_mobile/modules/profile/widgets/build_profile_card.dart';
import 'package:function_mobile/modules/profile/widgets/build_profile_options.dart';
import 'package:function_mobile/modules/profile/models/profile_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => profileController.refreshProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.of(context).viewPadding.top + 16,
                      16,
                      16,
                    ),
                    child: Column(
                      children: [
                        Obx(() {
                          final user = authController.user.value;
                          final profile = user != null
                              ? ProfileModel.fromAuthUser(user)
                              : ProfileModel();

                          return buildProfileCard(
                            context,
                            user,
                            profile,
                            () => profileController.navigateToEditProfile(),
                            profileController,
                          );
                        }),
                        SizedBox(height: 40),
                        buildProfileOptions(context, profileController),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
