import 'package:flutter/material.dart';

class VenueListPage extends StatelessWidget {
  const VenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text('data'),
                ),
              );
            },
            itemCount: 10,
          ),
        ),
      ),
    );
  }
}
