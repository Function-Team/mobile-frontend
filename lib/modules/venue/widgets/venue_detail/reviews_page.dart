import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('No reviews yet'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Add your review submission logic here
                },
                child: const Text('Add Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
