import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Styles/app_style.dart';

class CategoriesHeader extends StatelessWidget {
  final String category;
  final String action;
  final VoidCallback onTap;
  const CategoriesHeader({super.key, required this.category, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  action,
                  style:
                  TextStyle(color: AppStyle.mainColor, fontSize: 20),
                ),
                Icon(
                  CupertinoIcons.right_chevron,
                  color: AppStyle.mainColor,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
