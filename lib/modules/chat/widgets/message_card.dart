import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final String sender;
  final String message;
  final String timestamp;
  final String? profileImageUrl;
  final String? imageUrl;

  const MessageCard(
      {super.key,
      required this.sender,
      required this.message,
      required this.timestamp,
      this.profileImageUrl,
      this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Theme.of(context).colorScheme.onSurface,
      title: Text(sender),
      subtitle: Text(message),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timestamp),
        ],
      ),
      minLeadingWidth: 60,
      minTileHeight: 90,
      leading: CircleAvatar(
        radius: 30,
        child: profileImageUrl != null
            ? ClipOval(
                child: Image.network(
                  profileImageUrl!,
                  width: 60,
                ),
              )
            : Icon(Icons.person),
      ),
    );
  }
}
