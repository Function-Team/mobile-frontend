import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String? hintText;
  final IconData? icon;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final double width;
  final double height;

  const SearchTextField({
    this.icon,
    this.hintText,
    required this.controller,
    this.onChanged,
    this.width = double.infinity,
    this.height = 50,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
        ),
      ),
    );
  }
}
