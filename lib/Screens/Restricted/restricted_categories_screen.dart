import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Models/category_model.dart';
import 'package:pet_match/Styles/app_style.dart';
import 'package:provider/provider.dart';

import '../../Services/firebase_services.dart';

class RestrictedCategoriesScreen extends StatefulWidget {
  const RestrictedCategoriesScreen({super.key});

  @override
  State<RestrictedCategoriesScreen> createState() =>
      _RestrictedCategoriesScreenState();
}

class _RestrictedCategoriesScreenState
    extends State<RestrictedCategoriesScreen> {
  List<CategoryModel> categories = [];

  Future<void> getCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseServices.firestore
          .collection(FirebaseServices.categoriesCollection)
          .get();
      categories = snapshot.docs
          .map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final excludedCategoriesId =
        context.watch<GlobalVariables>().excludedCategories;
    final excludedCategories = categories
        .where(
          (element) => excludedCategoriesId.contains(element.id),
        )
        .toList();
    final unExcludedCategories = categories
        .where(
          (element) => !excludedCategoriesId.contains(element.id),
        )
        .toList();
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(CupertinoIcons.back)),
          title: const Text("Restricted Categories"),
        ),
        body: categories.isEmpty ? const Center(
          child: CircularProgressIndicator(),
        ) : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Excluded Categories",
                  style: TextStyle(
                      color: AppStyle.accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              excludedCategories.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final category = excludedCategories[index];
                        return listItem(
                            category: category,
                            color: AppStyle.accentColor,
                            onTap: () {
                              context
                                  .read<GlobalVariables>()
                                  .includeCategory(category.id!);
                              GlobalVariables.getCategories();
                            }).animate().fade();
                      },
                      separatorBuilder: (context, index) => SizedBox(
                            height: mq.height * .001,
                          ),
                      itemCount: excludedCategories.length)
                  : const Center(
                      child: Text(
                      "No Categories Excluded!",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    )),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Other Categories",
                  style: TextStyle(
                      color: AppStyle.accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              unExcludedCategories.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final category = unExcludedCategories[index];
                        return listItem(
                            category: category,
                            color: AppStyle.mainColor,
                            onTap: () {
                              context
                                  .read<GlobalVariables>()
                                  .excludeCategory(category.id!);
                              GlobalVariables.getCategories();
                            }).animate().fade();
                      },
                      separatorBuilder: (context, index) => SizedBox(
                            height: mq.height * .001,
                          ),
                      itemCount: unExcludedCategories.length)
                  : const Center(
                      child: Text(
                      "No Categories here!",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    )),
            ],
          ),
        ).animate().fade(),
      ),
    );
  }

  Widget listItem(
      {required CategoryModel category,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(.3),
              border: Border.all(color: color)),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Image.network(
                  category.image,
                  scale: 15,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Text(
                category.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
