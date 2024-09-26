import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:pet_match/Screens/MainScreens/FavoriteWidgets/all_favorites.dart';
import 'package:pet_match/Widgets/search_field.dart';
import 'package:provider/provider.dart';
import '../Constants/global_variables.dart';
import '../Models/category_model.dart';
import '../Models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController controller = TextEditingController();
  List<PetModel> pets = [];

  @override
  void initState() {
    getPets();
    super.initState();
  }

  getPets() async {
    await GlobalVariables.getPets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    if (controller.text.trim().isNotEmpty) {
      pets = context
          .watch<GlobalVariables>()
          .allPets
          .where((pet) =>
              pet.name
                  .toLowerCase()
                  .contains(controller.text.trim().toLowerCase()) ||
              pet.breed
                  .toLowerCase()
                  .contains(controller.text.trim().toLowerCase()))
          .toList();
      List<CategoryModel> categories = GlobalVariables.categories
          .where(
            (element) => element.name
                .toLowerCase()
                .contains(controller.text.trim().toLowerCase()),
          )
          .toList();
      List<User> users = GlobalVariables.users
          .where(
            (element) => element.name
                .toLowerCase()
                .contains(controller.text.trim().toLowerCase()),
          )
          .toList();
      final petsFromUsers = users.map((e) => context
          .watch<GlobalVariables>()
          .allPets
          .where(
            (pet) => pet.ownerId == e.id,
          )
          .toList());
      final petsFromCategory = categories.map(
        (e) => context
            .watch<GlobalVariables>()
            .allPets
            .where((pet) => pet.category == e.id)
            .toList(),
      );
      pets.addAll(petsFromCategory.expand((i) => i).toList());
      pets.addAll(petsFromUsers.expand((i) => i).toList());
      pets = pets.toSet().toList();
    } else {
      pets = [];
    }
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 100,
          title: SearchField(
            controller: controller,
            isSearchScreen: true,
            onChanged: (value) {
              setState(() {
                controller.text = value;
              });
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: mq.height * .05, horizontal: 18),
            child: ListView.builder(
              itemCount: pets.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return AllFavorites(pet: pets[index])
                    .animate()
                    .slideY(begin: 1, end: 0, duration: 200.ms);
              },
            ),
          ),
        ),
      ),
    );
  }
}
