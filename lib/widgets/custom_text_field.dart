import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String text;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.text,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      textCapitalization: widget.textCapitalization,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: widget.text,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Colors.blue)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
