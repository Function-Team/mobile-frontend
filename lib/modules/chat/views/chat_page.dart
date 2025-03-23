import 'package:flutter/material.dart';
import 'package:function_mobile/modules/chat/widgets/chat_list.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats',
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(
        child: ChatList(),
      ),
    );
  }
}
