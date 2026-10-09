import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onpressed;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onpressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: Colors.grey,
          backgroundColor: Colors.lightBlue,
        ),
        onPressed: onpressed,
        child: Text(text),
      ),
    );
  }
}
