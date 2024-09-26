import 'dart:io';

import 'package:animations/animations.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_match/Screens/AdoptionProcedure/adoption_screen.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:provider/provider.dart';

import '../Constants/global_variables.dart';
import '../Models/pet_model.dart';
import '../Styles/app_style.dart';
import '../Widgets/custom_text_field.dart';
import '../date_format.dart';
import 'MainScreens/ProfileWidgets/custom_back_button.dart';
import 'PetDetailsWidgets/action_widgets.dart';
import 'PetDetailsWidgets/age_weight.dart';
import 'PetDetailsWidgets/name_header.dart';
import 'PetDetailsWidgets/owner_header.dart';
import 'PetDetailsWidgets/pet_images_card.dart';

class MyPetsDetails extends StatefulWidget {
  final PetModel pet;

  const MyPetsDetails({super.key, required this.pet});

  @override
  State<MyPetsDetails> createState() => _MyPetsDetailsState();
}

class _MyPetsDetailsState extends State<MyPetsDetails> {
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    PetModel myPet = context
        .watch<GlobalVariables>()
        .allPets
        .firstWhere((element) => widget.pet.id == element.id);
    final mq = MediaQuery.of(context).size;
    TextEditingController nameController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController lastVaccinatedController = TextEditingController();
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  PetImagesCard(
                    pet: myPet,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            final List<XFile> pickedFile =
                                await ImagePicker().pickMultiImage();
                            for (var image in pickedFile) {
                              setState(() {
                                isUploading = true;
                              });
                              final timeStamp =
                                  DateTime.now().millisecondsSinceEpoch;
                              FirebaseStorage storage =
                                  FirebaseStorage.instance;
                              Reference ref = storage.ref().child('pets/${myPet.id}/$timeStamp');
                              await ref.putFile(File(image.path));
                              myPet.images.add(await ref.getDownloadURL());
                              FirebaseServices.firestore
                                  .collection(FirebaseServices.petsCollection)
                                  .doc(myPet.id)
                                  .update({'images': myPet.images});
                              setState(() {
                                isUploading = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: const Text('Add more images'),
                        ),
                      ],
                    ),
                  ),
                  NameHeader(pet: myPet),
                  OwnerHeader(
                    pet: myPet,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: AgeWeight(pet: myPet),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 18),
                    child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Breed: ${myPet.breed}',
                          style: TextStyle(
                              color: AppStyle.mainColor, fontSize: 18),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        myPet.description,
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: myPet.lastVaccinated != null &&
                            myPet.lastVaccinated!.isNotEmpty
                        ? Text(
                            "Last Vaccinated: ${DateFormat.getCreatedTime(context: context, time: myPet.lastVaccinated!)}")
                        : const Text("Not Vaccinated yet!"),
                  ),
                  myPet.status == 'Adopted'
                      ? Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                      '${myPet.name} is adopted, you\'re no longer the owner',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    )),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        )
                      : widget.pet.status == 'Approved'
                          ? Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OpenContainer(
                                    openColor: Colors.transparent,
                                    closedColor: Colors.transparent,
                                    closedElevation: 0,
                                    openElevation: 0,
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
                                            'Give ${widget.pet.name}',
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
                                        AdoptionScreen(pet: myPet),
                                  ),
                                )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ActionWidgets(
                                    color: AppStyle.ternaryColor,
                                    icon: Icons.edit,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String vaccinatedDate = '';
                                          nameController.text = myPet.name;
                                          descriptionController.text =
                                              myPet.description;
                                          weightController.text =
                                              myPet.weight.toString();
                                          if (myPet.lastVaccinated != null &&
                                              myPet
                                                  .lastVaccinated!.isNotEmpty) {
                                            lastVaccinatedController.text =
                                                DateFormat.getDate(
                                                    context: context,
                                                    date:
                                                        myPet.lastVaccinated!);
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
                                                        child: Text(
                                                            "Description")),
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
                                                            builder: (context,
                                                                state) {
                                                          return CustomTextField(
                                                            onTap: () async {
                                                              DateTime now =
                                                                  DateTime
                                                                      .now();
                                                              final pickedDate = await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  firstDate: DateTime
                                                                      .fromMillisecondsSinceEpoch(
                                                                          int.parse(myPet
                                                                              .dob)),
                                                                  lastDate:
                                                                      now);
                                                              if (pickedDate !=
                                                                  null) {
                                                                state(() {
                                                                  vaccinatedDate =
                                                                      pickedDate
                                                                          .millisecondsSinceEpoch
                                                                          .toString();
                                                                  lastVaccinatedController.text = DateFormat.getDate(
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
                                                        name: nameController
                                                            .text
                                                            .trim(),
                                                        pet: widget.pet,
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
                                                            pet: myPet,
                                                            name: nameController
                                                                .text,
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
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ActionWidgets(
                                    color: AppStyle.accentColor,
                                    icon: CupertinoIcons.delete,
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
                                                    Navigator.pop(context);
                                                    context
                                                        .read<GlobalVariables>()
                                                        .deletePet(
                                                            pet: widget.pet);
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
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: (){
                                      if(myPet.status != 'Given'){
                                        context.read<GlobalVariables>().updatePetStatus(pet: myPet, newStatus: 'Requested');
                                      } else if(myPet.status == 'Given'){
                                        showDialog(context: context, builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Adoption in progress'),
                                            content: Text('Adoption in progress. Do you want to cancel the procedure and take back ${myPet.name}'),
                                            actions: [
                                              TextButton(onPressed: (){
                                                Navigator.pop(context);
                                                context.read<GlobalVariables>().cancelAdoption(pet: myPet);
                                              }, child: const Text("Yes")),
                                              TextButton(onPressed: (){
                                                Navigator.pop(context);
                                              }, child: const Text("No")),
                                            ],
                                          );
                                        },);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: AppStyle.mainColor),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Text(
                                            myPet.status == 'Given'
                                                ? 'Adoption in progress...'
                                                : 'Request Again',
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
                                  ),
                                )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ActionWidgets(
                                    color: AppStyle.ternaryColor,
                                    icon: Icons.edit,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          String vaccinatedDate = '';
                                          nameController.text = myPet.name;
                                          descriptionController.text =
                                              myPet.description;
                                          weightController.text =
                                              myPet.weight.toString();
                                          if (myPet.lastVaccinated != null &&
                                              myPet
                                                  .lastVaccinated!.isNotEmpty) {
                                            lastVaccinatedController.text =
                                                DateFormat.getDate(
                                                    context: context,
                                                    date:
                                                        myPet.lastVaccinated!);
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
                                                        child: Text(
                                                            "Description")),
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
                                                            builder: (context,
                                                                state) {
                                                          return CustomTextField(
                                                            onTap: () async {
                                                              DateTime now =
                                                                  DateTime
                                                                      .now();
                                                              final pickedDate = await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  firstDate: DateTime
                                                                      .fromMillisecondsSinceEpoch(
                                                                          int.parse(myPet
                                                                              .dob)),
                                                                  lastDate:
                                                                      now);
                                                              if (pickedDate !=
                                                                  null) {
                                                                state(() {
                                                                  vaccinatedDate =
                                                                      pickedDate
                                                                          .millisecondsSinceEpoch
                                                                          .toString();
                                                                  lastVaccinatedController.text = DateFormat.getDate(
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
                                                        name: nameController
                                                            .text
                                                            .trim(),
                                                        pet: widget.pet,
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
                                                            pet: myPet,
                                                            name: nameController
                                                                .text,
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
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ActionWidgets(
                                    color: AppStyle.accentColor,
                                    icon: CupertinoIcons.delete,
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
                                                    Navigator.pop(context);
                                                    context
                                                        .read<GlobalVariables>()
                                                        .deletePet(
                                                            pet: widget.pet);
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
                                  ),
                                ),
                              ],
                            ),
                  SizedBox(height: mq.height * .01),
                  myPet.status == 'Requested'
                      ? Text(
                          "Your request is pending and will be approved soon!", style: TextStyle(color: AppStyle.mainColor), textAlign: TextAlign.center,)
                      : myPet.status == 'Declined'
                          ? Text(
                              "Unfortunately, Your request has been declined. You can request again to try once more.", style: TextStyle(color: AppStyle.accentColor), textAlign: TextAlign.center,)
                          : const SizedBox(),
                  SizedBox(
                    height: mq.height * .03,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mq.height * .03),
            child: CustomBackButton(onTap: () => Navigator.pop(context)),
          ),
          isUploading
              ? Container(
                  height: mq.height,
                  width: mq.width,
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppStyle.mainColor,
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
