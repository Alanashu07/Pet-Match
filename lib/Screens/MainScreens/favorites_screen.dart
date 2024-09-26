import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:provider/provider.dart';
import '../../Constants/global_variables.dart';
import '../../Widgets/search_field.dart';
import '../search_screen.dart';
import 'FavoriteWidgets/all_favorites.dart';
import 'FavoriteWidgets/favorites_list.dart';
import 'FavoriteWidgets/nearest_favorite.dart';
import 'HomeScreenWidgets/categories_header.dart';
import 'complete_favorites_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<PetModel> favoritePets = [];
    List<PetModel> nearestFavorite = [];
    List<PetModel> otherFavorites = [];
    final pets = context
        .watch<GlobalVariables>()
        .approvedPets
        .where(
          (element) => context
              .watch<GlobalVariables>()
              .user
              .favouritePets
              .contains(element.id),
        )
        .toList();
    favoritePets.addAll(pets);
    favoritePets = favoritePets.toSet().toList();
    favoritePets.sort(
      (a, b) => a.name.compareTo(b.name),
    );
    nearestFavorite = favoritePets
        .where(
          (pet) =>
              Geolocator.distanceBetween(
                  pet.latitude!,
                  pet.longitude!,
                  GlobalVariables.currentUser.latitude!,
                  GlobalVariables.currentUser.longitude!) <
              25000,
        )
        .toList();
    otherFavorites = favoritePets
        .where(
          (pet) =>
              Geolocator.distanceBetween(
                  pet.latitude!,
                  pet.longitude!,
                  GlobalVariables.currentUser.latitude!,
                  GlobalVariables.currentUser.longitude!) >
              25000,
        )
        .toList();
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: favoritePets.isEmpty
            ? SizedBox(
                height: mq.height,
                width: mq.width,
                child: const Center(
                  child: Text("No Favorite Pets added yet!"),
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 20),
                    child: SearchField(
                      controller: searchController,
                      borderRadius: 12,
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: const SearchScreen(),
                                type: PageTransitionType.fade));
                      },
                    ),
                  ).animate().slideY().fade(),
                  CategoriesHeader(
                          category: 'Favorites near you',
                          action: 'View All',
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: CompleteFavoritesScreen(
                                        title: 'Favorites near you',
                                        pets: nearestFavorite),
                                    type: PageTransitionType.rightToLeft));
                          })
                      .animate()
                      .scale(begin: const Offset(2, 2), end: const Offset(1, 1))
                      .fade(),
                  NearestFavorite(pets: nearestFavorite)
                      .animate()
                      .saturate()
                      .fade(),
                  CategoriesHeader(
                      category: 'Other Favorites',
                      action: 'View All',
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: CompleteFavoritesScreen(
                                    title: 'Other Favorites',
                                    pets: otherFavorites),
                                type: PageTransitionType.rightToLeft));
                      }).animate().scale().fade(),
                  FavoritesList(pets: otherFavorites)
                      .animate()
                      .slideX(begin: 1, end: 0)
                      .fade(),
                  SizedBox(
                    height: mq.height * .04,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return AllFavorites(pet: favoritePets[index]);
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 15,
                    ),
                    itemCount: favoritePets.length,
                  ),
                  SizedBox(
                    height: mq.height * .1,
                  )
                ],
              ),
      ),
    );
  }
}
