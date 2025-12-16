import 'package:flutter/material.dart';
import '../core/core.dart';

/// Custom text field with icon prefix and underline style.
/// Matches the Healthify design language with icon + vertical divider prefix.
class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.inputType,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      validator: widget.validator,
      obscureText: widget.isPassword ? _obscureText : false,
      style: const TextStyle(
        color: AppTheme.black,
        fontSize: AppConstants.fontSizeMedium,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppTheme.grey500,
          fontSize: AppConstants.fontSizeMedium,
        ),
        prefixIcon: widget.icon != null
            ? Container(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: AppTheme.grey700, size: 22),
                    const SizedBox(width: 8),
                    Container(height: 20, width: 2, color: AppTheme.grey400),
                  ],
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.isPassword
            ? IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.grey600,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: const UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.grey400),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        isDense: true,
        filled: false,
      ),
    );
  }
}
