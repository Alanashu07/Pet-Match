import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Screens/MainScreens/ChatHomeWidgets/chatting_screen.dart';
import 'package:provider/provider.dart';
import '../../../Models/pet_model.dart';
import '../../../Services/firebase_services.dart';
import '../../../Widgets/custom_text_field.dart';
import '../../../date_format.dart';
import '../../AdoptionProcedure/adoption_screen.dart';
import '../../pet_details_screen.dart';

class AllFavorites extends StatelessWidget {
  final PetModel pet;

  const AllFavorites({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final owner = GlobalVariables.users.firstWhere(
      (element) => element.id == pet.ownerId,
    );
    final user = context.watch<GlobalVariables>().user;
    bool isOwner = pet.ownerId == user.id;
    return OpenContainer(
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      openElevation: 0,
      closedElevation: 0,
      closedBuilder: (context, action) {
        return Column(
          children: [
            SizedBox(
                width: mq.width,
                height: mq.height * .3,
                child: Image.network(
                  pet.images[0],
                  fit: BoxFit.cover,
                )),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(owner.image ?? GlobalVariables.errorImage),
              ),
              title: Text(
                pet.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  '${pet.breed} • Owned by ${owner.name} • ${DateFormat.getCreatedTime(context: context, time: pet.createdAt)}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) {
                  return isOwner
                      ? pet.status == 'Approved'
                          ? [
                              PopupMenuItem(
                                  onTap: () {
                                    TextEditingController nameController =
                                        TextEditingController();
                                    TextEditingController
                                        descriptionController =
                                        TextEditingController();
                                    TextEditingController weightController =
                                        TextEditingController();
                                    TextEditingController
                                        lastVaccinatedController =
                                        TextEditingController();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        String vaccinatedDate =
                                            pet.lastVaccinated ?? '';
                                        nameController.text = pet.name;
                                        descriptionController.text =
                                            pet.description;
                                        weightController.text =
                                            pet.weight.toString();
                                        if (pet.lastVaccinated != null &&
                                            pet.lastVaccinated!.isNotEmpty) {
                                          lastVaccinatedController.text =
                                              DateFormat.getDate(
                                                  context: context,
                                                  date: pet.lastVaccinated!);
                                        }
                                        return AlertDialog(
                                          title: const Text('Edit your pet'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Text("Name")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: CustomTextField(
                                                        controller:
                                                            nameController,
                                                        hintText:
                                                            'Name of your pet',
                                                        type: 'name',
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child:
                                                          Text("Description")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: CustomTextField(
                                                        controller:
                                                            descriptionController,
                                                        hintText:
                                                            'Description of your pet',
                                                        type: 'description',
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Text("Weight")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: CustomTextField(
                                                        controller:
                                                            weightController,
                                                        hintText:
                                                            'Weight of your pet',
                                                        type: 'weight',
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          "Last Vaccinated")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: StatefulBuilder(
                                                          builder:
                                                              (context, state) {
                                                        return CustomTextField(
                                                          readOnly: true,
                                                          onTap: () async {
                                                            DateTime now =
                                                                DateTime.now();
                                                            final pickedDate = await showDatePicker(
                                                                context:
                                                                    context,
                                                                firstDate: DateTime
                                                                    .fromMillisecondsSinceEpoch(
                                                                        int.parse(
                                                                            pet.dob)),
                                                                lastDate: now);
                                                            if (pickedDate !=
                                                                null) {
                                                              state(() {
                                                                vaccinatedDate =
                                                                    pickedDate
                                                                        .millisecondsSinceEpoch
                                                                        .toString();
                                                                lastVaccinatedController
                                                                        .text =
                                                                    DateFormat.getDate(
                                                                        context:
                                                                            context,
                                                                        date: pickedDate
                                                                            .millisecondsSinceEpoch
                                                                            .toString());
                                                              });
                                                            }
                                                          },
                                                          controller:
                                                              lastVaccinatedController,
                                                          hintText:
                                                              'Last Vaccinated Date',
                                                          type:
                                                              'last Vaccinated',
                                                        );
                                                      })),
                                                ],
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  FirebaseServices.updatePet(
                                                      name: nameController.text
                                                          .trim(),
                                                      pet: pet,
                                                      description:
                                                          descriptionController
                                                              .text
                                                              .trim(),
                                                      weight: double.parse(
                                                          weightController.text
                                                              .trim()),
                                                      lastVaccinated:
                                                          vaccinatedDate);
                                                  context
                                                      .read<GlobalVariables>()
                                                      .updatePet(
                                                          pet: pet,
                                                          name: nameController
                                                              .text,
                                                          weight: double.parse(
                                                              weightController
                                                                  .text
                                                                  .trim()),
                                                          description:
                                                              descriptionController
                                                                  .text
                                                                  .trim(),
                                                          lastVaccinated:
                                                              vaccinatedDate);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Submit')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel')),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Edit this pet'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Icon(Icons.edit)
                                    ],
                                  )),
                              PopupMenuItem(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('You sure?'),
                                          content: const Text(
                                              'Are you sure you want to remove this pet from being adopted?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  context
                                                      .read<GlobalVariables>()
                                                      .deletePet(pet: pet);
                                                },
                                                child: const Text('Yes')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('No')),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Delete this pet'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Icon(CupertinoIcons.delete)
                                    ],
                                  )),
                              PopupMenuItem(
                                  onTap: () => Navigator.push(
                                      context,
                                      PageTransition(
                                          child: AdoptionScreen(
                                            pet: pet,
                                          ),
                                          type:
                                              PageTransitionType.bottomToTop)),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Give for adoption'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Icon(Icons.pets)
                                    ],
                                  )),
                            ]
                          : [
                              PopupMenuItem(
                                  onTap: () {
                                    TextEditingController nameController =
                                        TextEditingController();
                                    TextEditingController
                                        descriptionController =
                                        TextEditingController();
                                    TextEditingController weightController =
                                        TextEditingController();
                                    TextEditingController
                                        lastVaccinatedController =
                                        TextEditingController();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        String vaccinatedDate =
                                            pet.lastVaccinated ?? '';
                                        nameController.text = pet.name;
                                        descriptionController.text =
                                            pet.description;
                                        weightController.text =
                                            pet.weight.toString();
                                        if (pet.lastVaccinated != null &&
                                            pet.lastVaccinated!.isNotEmpty) {
                                          lastVaccinatedController.text =
                                              DateFormat.getDate(
                                                  context: context,
                                                  date: pet.lastVaccinated!);
                                        }
                                        return AlertDialog(
                                          title: const Text('Edit your pet'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Text("Name")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: CustomTextField(
                                                        controller:
                                                            nameController,
                                                        hintText:
                                                            'Name of your pet',
                                                        type: 'name',
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child:
                                                          Text("Description")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: CustomTextField(
                                                        controller:
                                                            descriptionController,
                                                        hintText:
                                                            'Description of your pet',
                                                        type: 'description',
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Text("Weight")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: CustomTextField(
                                                        controller:
                                                            weightController,
                                                        hintText:
                                                            'Weight of your pet',
                                                        type: 'weight',
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          "Last Vaccinated")),
                                                  const Text(":"),
                                                  Expanded(
                                                      flex: 3,
                                                      child: StatefulBuilder(
                                                          builder:
                                                              (context, state) {
                                                        return CustomTextField(
                                                          readOnly: true,
                                                          onTap: () async {
                                                            DateTime now =
                                                                DateTime.now();
                                                            final pickedDate = await showDatePicker(
                                                                context:
                                                                    context,
                                                                firstDate: DateTime
                                                                    .fromMillisecondsSinceEpoch(
                                                                        int.parse(
                                                                            pet.dob)),
                                                                lastDate: now);
                                                            if (pickedDate !=
                                                                null) {
                                                              state(() {
                                                                vaccinatedDate =
                                                                    pickedDate
                                                                        .millisecondsSinceEpoch
                                                                        .toString();
                                                                lastVaccinatedController
                                                                        .text =
                                                                    DateFormat.getDate(
                                                                        context:
                                                                            context,
                                                                        date: pickedDate
                                                                            .millisecondsSinceEpoch
                                                                            .toString());
                                                              });
                                                            }
                                                          },
                                                          controller:
                                                              lastVaccinatedController,
                                                          hintText:
                                                              'Last Vaccinated Date',
                                                          type:
                                                              'last Vaccinated',
                                                        );
                                                      })),
                                                ],
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  FirebaseServices.updatePet(
                                                      name: nameController.text
                                                          .trim(),
                                                      pet: pet,
                                                      description:
                                                          descriptionController
                                                              .text
                                                              .trim(),
                                                      weight: double.parse(
                                                          weightController.text
                                                              .trim()),
                                                      lastVaccinated:
                                                          vaccinatedDate);
                                                  context
                                                      .read<GlobalVariables>()
                                                      .updatePet(
                                                          pet: pet,
                                                          name: nameController
                                                              .text,
                                                          weight: double.parse(
                                                              weightController
                                                                  .text
                                                                  .trim()),
                                                          description:
                                                              descriptionController
                                                                  .text
                                                                  .trim(),
                                                          lastVaccinated:
                                                              vaccinatedDate);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Submit')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel')),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Edit this pet'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Icon(Icons.edit)
                                    ],
                                  )),
                              PopupMenuItem(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('You sure?'),
                                          content: const Text(
                                              'Are you sure you want to remove this pet from being adopted?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  context
                                                      .read<GlobalVariables>()
                                                      .deletePet(pet: pet);
                                                },
                                                child: const Text('Yes')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('No')),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Delete this pet'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Icon(CupertinoIcons.delete)
                                    ],
                                  )),
                              PopupMenuItem(
                                  onTap: () {
                                    context
                                        .read<GlobalVariables>()
                                        .updatePetStatus(
                                            pet: pet, newStatus: 'Requested');
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Submitted!"),
                                          content: const Text(
                                              "Your request has been submitted successfully!"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("OK"))
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Request again'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Icon(CupertinoIcons.doc_checkmark_fill)
                                    ],
                                  )),
                            ]
                      : [
                          PopupMenuItem(
                              onTap: () => Navigator.push(
                                  context,
                                  PageTransition(
                                      child: ChattingScreen(
                                        chatUser: owner,
                                        pet: pet,
                                        user: GlobalVariables.currentUser,
                                        adoptionRequest:
                                            "Hello ${owner.name}, I am ${GlobalVariables.currentUser.name}. I would like to adopt ${pet.name}  of breed: ${pet.breed}\nwith age ${DateFormat.getAge(context: context, dob: pet.dob)},\nweight: ${pet.weight}kg.\n\n If you are interested We can discuss further.",
                                      ),
                                      type: PageTransitionType.bottomToTop)),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Adopt Pet'),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Icon(Icons.pets)
                                ],
                              )),
                          PopupMenuItem(
                              onTap: () {
                                context
                                    .read<GlobalVariables>()
                                    .addToFavorite(petId: pet.id!);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(user.favouritePets.contains(pet.id!)
                                      ? 'Remove from favorites'
                                      : 'Add to favorites'),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  const Icon(Icons.favorite)
                                ],
                              )),
                          PopupMenuItem(
                              onTap: () {
                                context
                                    .read<GlobalVariables>()
                                    .excludePet(pet.id!);
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Don\'t show me this'),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Icon(CupertinoIcons.eye_slash_fill)
                                ],
                              )),
                          PopupMenuItem(
                              onTap: () {
                                TextEditingController suspicionController =
                                    TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          const Text("Explain your suspicion"),
                                      content: CustomTextField(
                                        controller: suspicionController,
                                        hintText: "Explain your suspicion",
                                        type: 'Suspicion',
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                      ),
                                      actions: [
                                        TextButton(onPressed: (){
                                          String message = 'This pet looks suspicious!.\npetId: ${pet.id!}\nName: ${pet.name}\nBreed: ${pet.breed}\nDescription: ${pet.description}';
                                          FirebaseServices.firestore.collection(FirebaseServices.reportsCollection).add({
                                            'message': '$message\n\n${suspicionController.text.trim()}',
                                            'pet': pet.toJson(),
                                            'reportedBy': GlobalVariables.currentUser.id,
                                            'time': DateTime.now().millisecondsSinceEpoch.toString()
                                          });
                                          Navigator.pop(context);
                                        }, child: const Text('Submit')),
                                        TextButton(onPressed: (){
                                          Navigator.pop(context);
                                        }, child: const Text('Cancel')),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Report Suspicion'),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Icon(Icons.flag)
                                ],
                              )),
                        ];
                },
              ),
            ),
          ],
        );
      },
      openBuilder: (context, action) {
        return PetDetailsScreen(pet: pet);
      },
    );
  }
}
