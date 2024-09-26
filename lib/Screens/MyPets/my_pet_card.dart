import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Screens/AdoptionProcedure/adoption_screen.dart';
import 'package:provider/provider.dart';
import '../../Constants/global_variables.dart';
import '../../Models/pet_model.dart';
import '../../Services/firebase_services.dart';
import '../../Styles/app_style.dart';
import '../../Widgets/custom_text_field.dart';
import '../../date_format.dart';
import '../pet_details_screen.dart';

class MyPetCard extends StatelessWidget {
  final PetModel pet;
  final double padding;
  final double height;
  final double width;
  final double borderRadius;

  const MyPetCard(
      {super.key,
      required this.pet,
      this.padding = 16,
      this.height = 100,
      this.width = double.infinity,
      this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController lastVaccinatedController = TextEditingController();
    return Padding(
      padding: EdgeInsets.all(padding),
      child: OpenContainer(
        openColor: Colors.transparent,
        openElevation: 0,
        closedColor: Colors.transparent,
        closedElevation: 0,
        closedBuilder: (context, action) => Container(
        height: height,
        width: width,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppStyle.mainColor.withOpacity(0.1),
            border: Border.all(color: AppStyle.mainColor)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(pet.images[0]),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    pet.breed,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(DateFormat.getCreatedTime(
                    context: context, time: pet.createdAt)),
                pet.status == 'Requested'
                    ? PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String vaccinatedDate = pet.lastVaccinated ?? '';
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
                                            child: Text("Description")),
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
                                                          context: context,
                                                          firstDate: DateTime.fromMillisecondsSinceEpoch(int.parse(pet.dob)),
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
                                                    type: 'last Vaccinated',
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
                                            name: nameController
                                                .text
                                                .trim(),
                                            pet: pet,
                                            description:
                                            descriptionController
                                                .text
                                                .trim(),
                                            weight: double.parse(
                                                weightController
                                                    .text
                                                    .trim()),
                                            lastVaccinated:
                                            vaccinatedDate);
                                        context
                                            .read<GlobalVariables>()
                                            .updatePet(
                                            pet: pet,
                                            name:
                                            nameController.text,
                                            weight: double.parse(
                                                weightController
                                                    .text.trim()),
                                            description:
                                            descriptionController
                                                .text.trim(),
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
                        child: const Text('Edit details'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
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
                        child: const Text('Delete this pet'),
                      ),
                      PopupMenuItem(
                        value: 'again',
                        onTap: () {
                          context.read<GlobalVariables>().updatePetStatus(pet: pet, newStatus: 'Requested');
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Submitted!"),
                              content: const Text("Your request has been submitted successfully!"),
                              actions: [
                                TextButton(onPressed: (){
                                  Navigator.pop(context);
                                }, child: const Text("OK"))
                              ],
                            );
                          },);
                        },
                        child: const Text('Request again'),
                      ),
                    ];
                  },
                )
                    : pet.status == 'Given' || pet.status == 'Adopted' ? const SizedBox() : PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String vaccinatedDate = '';
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
                                            child: Text("Description")),
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
                                                          context: context,
                                                          firstDate: DateTime.fromMillisecondsSinceEpoch(int.parse(pet.dob)),
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
                                                    type: 'last Vaccinated',
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
                                            name: nameController
                                                .text
                                                .trim(),
                                            pet: pet,
                                            description:
                                            descriptionController
                                                .text
                                                .trim(),
                                            weight: double.parse(
                                                weightController
                                                    .text
                                                    .trim()),
                                            lastVaccinated:
                                            vaccinatedDate);
                                        context
                                            .read<GlobalVariables>()
                                            .updatePet(
                                            pet: pet,
                                            name:
                                            nameController.text,
                                            weight: double.parse(
                                                weightController
                                                    .text),
                                            description:
                                            descriptionController
                                                .text,
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
                        child: const Text('Edit details'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
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
                        } ,
                        child: const Text('Delete this pet'),
                      ),
                      PopupMenuItem(
                        value: 'adopt',
                        onTap: () => Navigator.push(context, PageTransition(child: AdoptionScreen(pet: pet,), type: PageTransitionType.bottomToTop)),
                        child: const Text('Give for adoption'),
                      ),
                    ];
                  },
                )
              ],
            )
          ],
        ),
      ), openBuilder: (context, action) => PetDetailsScreen(pet: pet),),
    );
  }
}
