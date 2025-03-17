import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String? hintText;
  final IconData? icon;
  final void Function(String)? onChanged;
  final TextEditingController controller;

  const SearchTextField({
    this.icon,
    this.hintText,
    required this.controller,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
      ),
    );
  }
}
