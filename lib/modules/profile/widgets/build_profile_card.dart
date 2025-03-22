import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';

Widget buildProfileCard(
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
      ),
    ),
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(top: 60),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            profilePicture != null && profilePicture.isNotEmpty
                ? NetworkImageWithLoader(
                    borderRadius: BorderRadius.circular(35),
                    imageUrl: profilePicture,
                    height: 70,
                    width: 70,
                  )
                : CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[400],
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 24),
              onPressed: onEdit,
              tooltip: "Edit Profile",
            ),
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          width: double.infinity,
          text: "View Profile",
          onPressed: onTapViewProfile,
        ),
      ],
    ),
  );
}
