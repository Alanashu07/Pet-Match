import 'package:flutter/material.dart';

import '../Styles/app_style.dart';

class LoginButton extends StatelessWidget {
  final double height;
  final double width;
  final Widget? child;
  final List<Color>? colors;
  final VoidCallback onTap;
  const LoginButton({super.key, this.height = 50, this.width = double.infinity, this.child, required this.onTap, this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors ?? [AppStyle.accentColor, AppStyle.mainColor]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
