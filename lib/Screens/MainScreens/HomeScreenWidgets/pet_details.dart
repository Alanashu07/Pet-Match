import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/global_variables.dart';
import '../../../Models/pet_model.dart';
import '../../../Styles/app_style.dart';
import '../../pet_details_screen.dart';

class PetDetails extends StatefulWidget {
  const PetDetails({super.key});

  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  late List<Widget> listImages;
  bool isLiked = false;
  late List<PetModel> pets;
  List<PetModel> sortedPets = [];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    pets = context
        .watch<GlobalVariables>()
        .approvedPets
        .where((element) =>
            element.ownerId != context.watch<GlobalVariables>().user.id &&
            !context.watch<GlobalVariables>().excludedPets.contains(element.id))
        .toList();
    sortedPets.addAll(pets);
    sortedPets = sortedPets.toSet().toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<GlobalVariables>().sortPets(sortedPets);
    });
    listImages = sortedPets.map(
      (pet) {
        return OpenContainer(
          openElevation: 0,
          closedElevation: 0,
          openColor: Colors.transparent,
          closedColor: Colors.transparent,
          closedBuilder: (context, action) {
            return Container(
              height: mq.height * .5,
              decoration: BoxDecoration(
                color: AppStyle.accentColor,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: NetworkImage(pet.images[0]), fit: BoxFit.cover),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                              onPressed: () {
                                context
                                    .read<GlobalVariables>()
                                    .addToFavorite(petId: pet.id!);
                              },
                              icon: context
                                      .watch<GlobalVariables>()
                                      .user
                                      .favouritePets
                                      .contains(pet.id)
                                  ? const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    )),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined),
                                    Expanded(
                                      child: Text(
                                        pet.location!,
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Image.asset(
                            pet.isMale
                                ? 'images/male.png'
                                : 'images/female.png',
                            scale: 15,
                            color: pet.isMale
                                ? AppStyle.mainColor
                                : AppStyle.accentColor,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          openBuilder: (context, action) {
            return PetDetailsScreen(pet: pet);
          },
        );
      },
    ).toList();

    return CarouselSlider(
        items: listImages,
        options: CarouselOptions(
          autoPlay: true,
          height: mq.height * .5,
          enlargeCenterPage: true,
        ));
  }
}
