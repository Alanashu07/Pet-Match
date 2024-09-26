import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../Models/category_model.dart';
import '../Screens/category_wise_pets.dart';
import '../Styles/app_style.dart';

class CategoryIcon extends StatelessWidget {
  final CategoryModel category;
  final double height;
  final double width;

  const CategoryIcon(
      {super.key, required this.category, this.height = 70, this.width = 70});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      closedBuilder: (context, action) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppStyle.categoryColor[category.colorIndex]
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppStyle.categoryColor[category.colorIndex])),
            child: Image.network(
              category.image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(category.name)
        ],
      );
    }, openBuilder: (context, action) {
      return CategoryWisePets(category: category);
    },);
  }
}
