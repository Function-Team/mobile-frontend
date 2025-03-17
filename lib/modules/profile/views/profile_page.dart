import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
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
                      _buildProfileCard(
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
                      _buildProfileOptions(context),
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

  Widget _buildProfileCard(
      {required BuildContext context,
      String? profilePicture,
      required String name,
      required String email,
      required VoidCallback onEdit,
      required VoidCallback onTapViewProfile}) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 0.25,
          )),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              profilePicture != null && profilePicture.isNotEmpty
                  ? NetworkImageWithLoader(
                      imageUrl: profilePicture,
                      width: 70,
                      height: 70,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[400],
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ],
          ),
          SizedBox(height: 16),
          PrimaryButton(
            text: 'View your Profile',
            onPressed: onTapViewProfile,
            width: double.infinity,
          )
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context: context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Payment Methods',
          subtitle: 'Add or remove payment methods',
          onTap: () {
            // Handle PAYMENT METHODS
          },
        ),
        SizedBox(height: 16),
        _buildOptionTile(
          context: context,
          icon: Icons.person_outline,
          title: 'Your Details',
          subtitle: 'Update your personal details',
          onTap: () {
            // Handle your details
          },
        ),
        _buildOptionTile(
          context: context,
          icon: Icons.money_off,
          title: 'Refunds',
          subtitle: 'Request a refund',
          onTap: () {
            // Handle refunds
          },
        ),
        _buildOptionTile(
          context: context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy',
          subtitle: 'View our privacy policy',
          onTap: () {
            // Handle privacy
          },
        ),
        _buildOptionTile(
          context: context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help with your account',
          onTap: () {
            // Handle help & support
          },
        ),
        _buildOptionTile(
          context: context,
          icon: Icons.headset_mic_outlined,
          title: 'Contact Us',
          subtitle: 'Get in touch with us',
          onTap: () {
            // Handle contact us
          },
        ),
        _buildOptionTile(
          context: context,
          icon: Icons.info_outline,
          title: 'About Us',
          subtitle: 'Learn more about us',
          onTap: () {
            // Handle about us
          },
        ),
        _buildOptionTile(
          context: context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Manage your account settings',
          onTap: () {
            // Handle settings
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 0.25,
          ),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
