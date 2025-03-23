import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/chat/widgets/chat_card.dart';
import 'package:get/get.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return ChatCard(
              onTap: () {
                Get.toNamed(MyRoutes.chatting);
              },
              sender: 'John Doe',
              message: 'Hi Im John Doe',
              timestamp: '12:00',
              imageUrl: 'https://picsum.photos/200',
              newMessageCount: 1,
            );
          },
        ),
      ),
    );
  }
}
