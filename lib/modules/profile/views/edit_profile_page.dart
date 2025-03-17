import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/inputs/primary_text_field.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildProfilePicture(context),
            const SizedBox(height: 24),
            _buildProfileForm(),
            const SizedBox(height: 30),
            SecondaryButton(
              text: 'Save Changes',
              onPressed: () {},
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
                onTap: () {}, // Tambahkan fungsi untuk upload gambar
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

  Widget _buildProfileForm() {
    return Column(
      children: [
        PrimaryTextField(
            label: 'Username',
            hintText: 'Enter your username',
            prefixIcon: Icon(Icons.person),
            keyboardType: TextInputType.text),
        SizedBox(height: 16),
        PrimaryTextField(
            label: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icon(Icons.email),
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: 16),
        PrimaryTextField(
            label: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: Icon(Icons.phone),
            keyboardType: TextInputType.phone),
      ],
    );
  }
}
