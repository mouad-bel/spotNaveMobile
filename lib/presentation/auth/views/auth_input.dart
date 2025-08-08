import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {
  static const _borderRadius = BorderRadius.all(Radius.circular(16));

  final TextEditingController controller;
  final String hint;
  final Widget prefix;
  final Widget? suffix;
  final bool obscureText;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefix,
    this.suffix,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        prefixIcon: prefix,
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black45,
        ),
        contentPadding: const EdgeInsets.all(0),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
