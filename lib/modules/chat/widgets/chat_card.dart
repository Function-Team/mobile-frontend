import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';

class ChatCard extends StatelessWidget {
  final String sender;
  final String message;
  final String timestamp;
  final String? imageUrl;
  final int newMessageCount;
  final VoidCallback onTap;

  const ChatCard(
      {super.key,
      required this.sender,
      required this.message,
      required this.timestamp,
      this.imageUrl,
      required this.newMessageCount,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 60,
      minTileHeight: 70,
      leading: CircleAvatar(
        radius: 25,
        child: imageUrl != null
            ? ClipOval(
                child: NetworkImageWithLoader(
                  imageUrl: imageUrl!,
                ),
              )
            : Icon(Icons.person),
      ),
      title: Text(sender),
      subtitle: Text(message),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timestamp),
          SizedBox(width: 10),
          newMessageCount > 0
              ? Badge.count(count: newMessageCount)
              : SizedBox(),
        ],
      ),
    );
  }
}
