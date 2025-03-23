import 'package:flutter/material.dart';
import 'package:function_mobile/modules/chat/widgets/message_card.dart';

class ChattingPage extends StatelessWidget {
  const ChattingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatting Page',
            style: Theme.of(context).textTheme.displaySmall),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            flex: 8,
            child: ListView.builder(
                itemCount: 8,
                itemBuilder: (BuildContext context, int index) {
                  return MessageCard(
                      sender: 'John Doe',
                      message: 'Hi!',
                      timestamp: '12:00',
                      profileImageUrl: 'https://picsum.photos/200');
                }),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
