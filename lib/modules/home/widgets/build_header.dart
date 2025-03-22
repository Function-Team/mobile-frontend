import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';

Widget buildHeader(
  BuildContext context, {
  required String name,
  required String? profilePicture,
  required VoidCallback onTapProfile,
}) {
  return Row(
    children: [
      Expanded(
        flex: 10,
        child: GestureDetector(
          onTap: onTapProfile,
          child: Row(
            children: [
              profilePicture != null && profilePicture.isNotEmpty
                  ? NetworkImageWithLoader(
                      imageUrl: profilePicture,
                      width: 40,
                      height: 40,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[400],
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              const SizedBox(width: 8),
              Text(
                'Hello, ',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.grey[300]),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Icon(
          Icons.notifications,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 24,
        ),
      ),
    ],
  );
}
