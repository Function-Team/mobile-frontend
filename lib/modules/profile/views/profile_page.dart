import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/profile/widgets/build_profile_card.dart';
import 'package:function_mobile/modules/profile/widgets/build_profile_options.dart';

import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
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
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                  child: Column(
                    children: [

                      buildProfileCard(

                        context: context,
                        profilePicture: "https://picsum.photos/200",
                        name: "John Doe",
                        email: "user@gmail.com",
                        onEdit: () {
                          Get.toNamed(MyRoutes.editProfile);
                        },
                        onTapViewProfile: () {},
                      ),
                      SizedBox(height: 40),
                      buildProfileOptions(context),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
