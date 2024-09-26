import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../Models/category_model.dart';
import '../../Styles/app_style.dart';
import '../category_wise_pets.dart';

class CategoriesList extends StatelessWidget {
  final CategoryModel category;
  const CategoriesList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      openBuilder: (context, action) {
        return CategoryWisePets(category: category);
      },
      closedBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppStyle.categoryColor[category.colorIndex].withOpacity(.3),
                border: Border.all(color: AppStyle.categoryColor[category.colorIndex])
            ),
            child: Row(
              children: [
                const SizedBox(width: 20,),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Image.network(category.image, scale: 15,),
                ),
                const SizedBox(width: 20,),
                Expanded(child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),))
              ],
            ),
          ),
        );
      },
    );
  }
}
