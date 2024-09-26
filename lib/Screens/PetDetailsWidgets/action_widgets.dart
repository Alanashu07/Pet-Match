import 'package:flutter/material.dart';

class ActionWidgets extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  const ActionWidgets({super.key, required this.color, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
          border: Border.all(color: color)
        ),
        child: Icon(icon, color: color, size: 30,),
      ),
    );
  }
}
