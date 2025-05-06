import 'package:flutter/material.dart';

class TabNav extends StatelessWidget {
  final int length;
  final List<Tab> tabs; // List of Tab widgets (icon, text, or both)
  final List<Widget> contents; // List of content widgets for each tab

  const TabNav({
    super.key,
    required this.length,
    required this.tabs, // Updated to accept a list of Tab widgets
    required this.contents, // Updated to accept a list of content widgets
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: length,
      child: Column(
        children: [
          TabBar(
            tabs: tabs, // Use the provided list of Tab widgets
          ),
          Flexible(
            child: TabBarView(
              children: contents, // Use the provided list of content widgets
            ),
          ),
        ],
      ),
    );
  }
}
