import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../Constants/global_variables.dart';
import '../../../Models/pet_model.dart';
import '../../../Styles/app_style.dart';
import '../../pet_details_screen.dart';

class NearestFavorite extends StatelessWidget {
  final List<PetModel> pets;

  const NearestFavorite({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    List<PetModel> nearestPets = [];
    nearestPets.addAll(pets);
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: nearestPets.isEmpty ? const Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Text("You don't have any favorite pets within 25km"),
        ),
      ) : GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: nearestPets.length >= 4 ? 4 : nearestPets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 20),
        itemBuilder: (context, index) {
          nearestPets.sort((a,b) {
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
          return OpenContainer(
            closedElevation: 0,
            closedColor: Colors.transparent,
            openElevation: 0,
            openColor: Colors.transparent,
            closedBuilder: (context, action) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          nearestPets[index].images[0],
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nearestPets[index].name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppStyle.mainColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              nearestPets[index].breed,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      Image.asset(
                        nearestPets[index].isMale
                            ? 'images/male.png'
                            : 'images/female.png',
                        scale: 15,
                        color: nearestPets[index].isMale
                            ? AppStyle.mainColor
                            : AppStyle.accentColor,
                      )
                    ],
                  ),
                ),
              ],
            );
          }, openBuilder: (context, action) {
            return PetDetailsScreen(pet: nearestPets[index]);
          },);
        },
      ),
    );
  }
}
