import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/common/routes/routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Settings'),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account Settings'),
              _buildSettingsItem(
                title: 'Edit Profile',
                onTap: () {
                  Get.toNamed(MyRoutes.editProfile);
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                title: 'Change Password',
                onTap: () {
                  // Navigate to Change Password Page
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              //NOTE: Optional Feature
              // _buildSettingsItem(
              //   title: 'Account Privacy',
              //   onTap: () {},
              //   trailing: Icon(Icons.keyboard_arrow_right),
              // ),
              SizedBox(height: 16),
              Text('Preferences'),
              _buildSettingsItem(
                title: 'Language',
                onTap: () {
                  // Navigate to Language Page
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                title: 'Notification',
                onTap: () {
                  // Navigate to Notification Page
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              SizedBox(height: 16),
              Text('About'),
              _buildSettingsItem(
                title: 'App Version',
                trailing: Text('1.0.0'),
              ),
              _buildSettingsItem(
                title: 'Privacy Policy',
                onTap: () {
                  Get.toNamed(MyRoutes.privacyPolicy);
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                title: 'Terms & Conditions',
                onTap: () {
                  // Navigate to Terms & Conditions Page
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              _buildSettingsItem(
                title: 'About Us',
                onTap: () {
                  // Navigate to About Us Page
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              SizedBox(height: 16),
              _buildSettingsItem(
                title: 'Logout',
                onTap: () {
                  //TODO: Implement Logout
                },
                textColor: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        )));
  }

  _buildSettingsItem(
      {required String title,
      VoidCallback? onTap,
      Color? textColor,
      Widget? trailing}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      trailing: trailing,
      textColor: textColor,
    );
  }
}
