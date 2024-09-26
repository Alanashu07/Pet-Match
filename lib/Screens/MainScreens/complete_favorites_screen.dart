import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../Constants/global_variables.dart';
import '../../Models/pet_model.dart';
import 'FavoriteWidgets/all_favorites.dart';

class CompleteFavoritesScreen extends StatelessWidget {
  final String title;
  final List<PetModel> pets;

  const CompleteFavoritesScreen(
      {super.key, required this.title, required this.pets});

  @override
  Widget build(BuildContext context) {
    List<PetModel> nearestPets = [];
    final excludedPets = context.watch<GlobalVariables>().excludedPets;
    final filteredPets = pets.where((element) => !excludedPets.contains(element.id),).toList();
    nearestPets.addAll(filteredPets);
    nearestPets = nearestPets.toSet().toList();
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: nearestPets.isNotEmpty
            ? ListView.separated(
                itemBuilder: (context, index) {
                  if (title == 'Favorites near you') {
                    nearestPets.sort((a, b) {
                      final distanceA = Geolocator.distanceBetween(
                          a.latitude!,
                          a.longitude!,
                          GlobalVariables.currentUser.latitude!,
                          GlobalVariables.currentUser.longitude!);
                      final distanceB = Geolocator.distanceBetween(
                          b.latitude!,
                          b.longitude!,
                          GlobalVariables.currentUser.latitude!,
                          GlobalVariables.currentUser.longitude!);
                      return distanceA.compareTo(distanceB);
                    });
                  }
                  return AllFavorites(pet: nearestPets[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 15,
                    ),
                itemCount: nearestPets.length)
            : const Center(
                child: Text('No pets found'),
              ),
      ),
    );
  }
}
