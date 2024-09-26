import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Styles/app_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String type;
  final int minLines;
  final int maxLines;
  final String? labelText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextStyle? hintStyle;
  final Color labelColor;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? textInputType;
  final TextCapitalization? textCapitalization;
  final bool hideText;

  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.readOnly = false,
      this.minLines = 1,
      this.maxLines = 5,
      this.focusNode,
      this.inputFormatters,
      this.onTap,
      this.hintStyle,
      this.labelColor = Colors.brown,
      this.prefixIcon,
      this.textInputType,
      this.suffixIcon,
      this.hideText = false,
      required this.type,
      this.labelText,
      this.textCapitalization});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TextFormField(
        maxLines: hideText ? 1 : maxLines,
        minLines: minLines,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        onTap: onTap,
        readOnly: readOnly,
        focusNode: focusNode,
        controller: controller,
        validator: (value) => value!.isNotEmpty ? null : "Enter $type",
        cursorColor: AppStyle.mainColor,
        obscureText: hideText,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          labelStyle: TextStyle(color: labelColor),
          hintStyle: hintStyle,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppStyle.mainColor)),
        ),
      ),
    );
  }
}
