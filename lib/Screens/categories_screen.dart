import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Constants/global_variables.dart';
import 'CategoriesWidgets/categories_list.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalVariables.getCategories();
    final mq = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.back)),
          title: const Text('Categories'),
          centerTitle: true,
        ),
        body: ListView.separated(
                padding: EdgeInsets.only(bottom: mq.height * .05),
                itemBuilder: (context, index) {
                  return CategoriesList(
                      category: GlobalVariables.categories[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                itemCount: GlobalVariables.categories.length)
            .animate()
            .slideY(
                begin: 1,
                end: 0,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300)),
      ),
    );
  }
}
