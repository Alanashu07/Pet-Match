import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Screens/MainScreens/ChatHomeWidgets/chatting_screen.dart';
import 'package:pet_match/Services/notification_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants/global_variables.dart';
import '../Models/pet_model.dart';
import '../Styles/app_style.dart';
import '../date_format.dart';
import 'MainScreens/ProfileWidgets/custom_back_button.dart';
import 'PetDetailsWidgets/action_widgets.dart';
import 'PetDetailsWidgets/age_weight.dart';
import 'PetDetailsWidgets/name_header.dart';
import 'PetDetailsWidgets/owner_header.dart';
import 'PetDetailsWidgets/pet_images_card.dart';

class OthersPetDetails extends StatelessWidget {
  final PetModel pet;

  const OthersPetDetails({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final distance = Geolocator.distanceBetween(
        pet.latitude!,
        pet.longitude!,
        GlobalVariables.currentUser.latitude!,
        GlobalVariables.currentUser.longitude!);
    final owner = GlobalVariables.users
        .firstWhere((element) => element.id == pet.ownerId);
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  PetImagesCard(
                    pet: pet,
                  ),
                  NameHeader(pet: pet),
                  Text(
                    distance > 1000
                        ? "Distance: ${(distance / 1000).toStringAsFixed(2)} km"
                        : "Distance: ${distance.toStringAsFixed(1)} m",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  OwnerHeader(
                    pet: pet,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: AgeWeight(pet: pet),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 18),
                    child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Breed: ${pet.breed}',
                          style: TextStyle(
                              color: AppStyle.mainColor, fontSize: 18),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        pet.description,
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: pet.lastVaccinated != null &&
                            pet.lastVaccinated!.isNotEmpty
                        ? Text(
                            "Last Vaccinated: ${DateFormat.getCreatedTime(context: context, time: pet.lastVaccinated!)}")
                        : const Text("Not Vaccinated yet!"),
                  ),
                  pet.status == 'Given' && context.watch<GlobalVariables>().user.adoptedPets.contains(pet.id) ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        ActionWidgets(color: Colors.blue, icon: Icons.location_on_outlined, onTap: () async {
                          final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${pet.latitude},${pet.longitude}");
                          if (await canLaunchUrl(url)) {
                            launchUrl(url);
                          }
                        },),
                        const SizedBox(width: 15,),
                        const Text('Open Google Map', style: TextStyle(color: Colors.blue),)
                      ],
                    ),
                  ) : const SizedBox(),
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: pet.status == 'Given' &&
                            context
                                .watch<GlobalVariables>()
                                .user
                                .adoptedPets
                                .contains(pet.id!)
                        ? Row(
                            key: const Key('0'),
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    context
                                        .read<GlobalVariables>()
                                        .updatePetStatus(
                                            pet: pet, newStatus: 'Adopted');
                                    NotificationServices.favoritePetAdopted(pet: pet, adoptedUser: GlobalVariables.currentUser);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Congratulations✨"),
                                          content: Text(
                                              "You have adopted ${pet.name}. Hope you take care ${pet.isMale ? "him" : "her"} well. Thank You!😍"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Welcome💕"))
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: AppStyle.accentColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Icon(
                                            Icons.pets,
                                            color: AppStyle.accentColor,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            child: Text(
                                          'Take ${pet.name} home',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          )
                        : pet.status == 'Adopted' || pet.status == 'Given'
                            ? Row(
                                key: const Key('1'),
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: AppStyle.accentColor),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              Icons.pets,
                                              color: AppStyle.accentColor,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Text(
                                            context
                                                    .watch<GlobalVariables>()
                                                    .user
                                                    .adoptedPets
                                                    .contains(pet.id)
                                                ? 'You have already adopted ${pet.name}'
                                                : '${pet.name} is already adopted',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          )),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              )
                            : Row(
                                key: const Key('2'),
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OpenContainer(
                                      openColor: Colors.transparent,
                                      closedColor: Colors.transparent,
                                      openElevation: 0,
                                      closedElevation: 0,
                                      closedBuilder: (context, action) =>
                                          Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: AppStyle.mainColor),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              'Adopt ${pet.name}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            )),
                                            Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: Icon(
                                                Icons.pets,
                                                color: AppStyle.mainColor,
                                                size: 30,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      openBuilder: (context, action) =>
                                          ChattingScreen(
                                        user: GlobalVariables.currentUser,
                                        pet: pet,
                                        chatUser: owner,
                                        adoptionRequest:
                                            "Hello ${owner.name}, I am ${GlobalVariables.currentUser.name}. I would like to adopt ${pet.name}  of breed: ${pet.breed}\nwith age ${DateFormat.getAge(context: context, dob: pet.dob)},\nweight: ${pet.weight}kg.\n\n If you are interested We can discuss further.",
                                      ),
                                    ),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ActionWidgets(
                                      color: AppStyle.ternaryColor,
                                      icon: Icons.call_outlined,
                                      onTap: () async {
                                        final url = Uri(
                                          scheme: 'tel',
                                          path: owner.phoneNumber,
                                        );
                                        if (await canLaunchUrl(url)) {
                                          launchUrl(url);
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OpenContainer(
                                      openElevation: 0,
                                      openColor: Colors.transparent,
                                      closedElevation: 0,
                                      closedColor: Colors.transparent,
                                      closedBuilder: (context, action) => ActionWidgets(
                                      color: AppStyle.accentColor,
                                      icon: CupertinoIcons.chat_bubble_text,
                                    ), openBuilder: (context, action) => ChattingScreen(user: GlobalVariables.currentUser, chatUser: owner),),
                                  ),
                                ],
                              ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mq.width * .03, vertical: mq.height * .05),
            child: CustomBackButton(onTap: () => Navigator.pop(context)),
          )
        ],
      ),
    );
  }
}
