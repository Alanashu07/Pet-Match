import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../Models/pet_model.dart';
import '../../../Styles/app_style.dart';
import '../../pet_details_screen.dart';

class FavoritesList extends StatelessWidget {
  final List<PetModel> pets;
  const FavoritesList({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Container(
      height: mq.height*.2,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: pets.isEmpty ? const Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Text("You don't have any favorite pets beyond 25km"),
        ),
      ) : ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
        return OpenContainer(
          openColor: Colors.transparent,
          closedColor: Colors.transparent,
          openElevation: 0,
          closedElevation: 0,
          closedBuilder: (context, action) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: mq.width*.4,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(pets[index].images[0], fit: BoxFit.cover,)),
                ),
              ),
              Text(pets[index].name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStyle.mainColor),),
              Text(pets[index].breed, style: const TextStyle(color: Colors.grey, fontSize: 16),)
            ],
          );
        }, openBuilder: (context, action) {
          return PetDetailsScreen(pet: pets[index]);
        },);
      }, separatorBuilder: (context, index) {
        return const SizedBox(width: 15,);
      }, itemCount: pets.length),
    );
  }
}
