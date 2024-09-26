import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../Constants/global_variables.dart';
import '../Models/accessory_model.dart';
import '../Models/category_model.dart';
import '../Models/pet_model.dart';
import '../Styles/app_style.dart';
import '../Widgets/accessory_thumbnail.dart';
import 'MainScreens/FavoriteWidgets/all_favorites.dart';

class CategoryWisePets extends StatelessWidget {
  final CategoryModel category;

  const CategoryWisePets({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    List<PetModel> pets = context
        .watch<GlobalVariables>()
        .approvedPets
        .where(
          (pet) => pet.category == category.id,
        )
        .toList();
    List<Accessory> accessories = context
        .watch<GlobalVariables>()
        .allAccessories
        .where((accessory) => accessory.category == category.id)
        .toList();
    final mq = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor:
            AppStyle.categoryColor[category.colorIndex].withOpacity(0.1),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.back)),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
          ),
          centerTitle: true,
        ),
        body: category.isPet
            ? pets.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.only(bottom: mq.height * .05),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return AllFavorites(pet: pets[index]).animate().slide();
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 15,
                        ),
                    itemCount: pets.length)
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              height: mq.width,
                              width: mq.width,
                              child: Image.network(category.emptyImage).animate().fade()),
                          const SizedBox(
                            height: 35,
                          ),
                          const Text(
                            'This category seems empty! Explore other categories and come back later🙃',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ).animate().slide()
            : accessories.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.only(bottom: mq.height * .05),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return AccessoryThumbnail(accessory: accessories[index]);
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 15,
                        ),
                    itemCount: accessories.length)
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              height: mq.width,
                              width: mq.width,
                              child: Image.network(category.emptyImage).animate().fade()),
                          const SizedBox(
                            height: 35,
                          ),
                          const Text(
                            'This category seems empty! Explore other categories and come back later🙃',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ).animate().slide(),
      ),
    );
  }
}
