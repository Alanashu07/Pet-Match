import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:pet_match/Screens/MainScreens/ProfileWidgets/custom_back_button.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:pet_match/Services/notification_services.dart';
import 'package:pet_match/main.dart';
import 'package:provider/provider.dart';
import '../../Constants/global_variables.dart';
import '../../Models/category_model.dart';
import '../../Models/user_model.dart';
import '../../Styles/app_style.dart';
import '../../Widgets/custom_text_field.dart';
import '../../Widgets/login_button.dart';
import '../../date_format.dart';
import 'image_added_container.dart';
import 'no_image_container.dart';

class NewPetScreen extends StatefulWidget {
  const NewPetScreen({super.key});

  @override
  State<NewPetScreen> createState() => _NewPetScreenState();
}

class _NewPetScreenState extends State<NewPetScreen> {
  List<XFile> images = [];
  bool isUploading = false;
  List<String> imageUrls = [];
  final _formKey = GlobalKey<FormState>();
  String gender = 'Male';
  bool isVaccinated = false;
  String dob = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController lastVaccinatedController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  String vaccinatedDate = '';
  CategoryModel? selectedCategory;
  User owner = GlobalVariables.currentUser;

  @override
  void initState() {
    contactNumController.text = owner.phoneNumber;
    super.initState();
  }

  uploadImages() async {
    for (var image in images) {
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('pets/${owner.id!}-$timeStamp');
      await ref.putFile(File(image.path));
      imageUrls.add(await ref.getDownloadURL());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<GlobalVariables>().user;
    final mq = MediaQuery.of(context).size;
    if (user.latitude == 0 ||
        user.longitude == 0 ||
        user.location!.isEmpty ||
        user.location == null ||
        user.latitude == null ||
        user.longitude == null ||
        enableLocation! == false) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.location_slash_fill,
                size: 50,
                color: Colors.red,
              ),
              const Text(
                'Please update your location first',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'You cannot add a pet without location. This is to help others find your pet. You have to be at the location of your pet.',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: mq.height * .05,
              ),
              CustomBackButton(onTap: () {
                Navigator.pop(context);
              })
            ],
          ),
        ),
      );
    }
    List<CategoryModel> categories = GlobalVariables.categories
        .where(
          (element) => element.isPet,
        )
        .toList();
    bool isMale = gender == 'Male';
    bool imageAdded = images.isNotEmpty;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(CupertinoIcons.back)),
            title: const Text(
              'Add new pet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                imageAdded
                    ? ImageAddedContainer(images: images)
                    : NoImageContainer(onTap: () async {
                        final picker = ImagePicker();
                        final List<XFile> pickedFile =
                            await picker.pickMultiImage();
                        setState(() {
                          images.addAll(pickedFile);
                        });
                      }),
                imageAdded
                    ? Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              onPressed: () async {
                                final List<XFile> pickedFile =
                                    await ImagePicker().pickMultiImage();
                                setState(() {
                                  images.addAll(pickedFile);
                                });
                              },
                              child: const Text('Add more images')),
                          const SizedBox(
                            width: 16,
                          )
                        ],
                      )
                    : Container(),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                          textCapitalization: TextCapitalization.words,
                          labelText: 'Name',
                          controller: nameController,
                          hintText: "Name of your pet",
                          type: 'name'),
                      CustomTextField(
                          textCapitalization: TextCapitalization.words,
                          labelText: 'Breed',
                          controller: breedController,
                          hintText: "Breed of your pet",
                          type: 'breed'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                Radio(
                                  value: 'Male',
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text('Male')
                              ],
                            )),
                            Expanded(
                                child: Row(
                              children: [
                                Radio(
                                  value: 'Female',
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text('Female')
                              ],
                            ))
                          ],
                        ),
                      ),
                      CustomTextField(
                          textCapitalization: TextCapitalization.sentences,
                          labelText: 'Description',
                          controller: descriptionController,
                          hintText: "Describe your pet",
                          type: 'description'),
                      CustomTextField(
                          readOnly: true,
                          onTap: () async {
                            DateTime now = DateTime.now();
                            final pickedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime(now.year)
                                    .subtract(const Duration(days: 10000)),
                                lastDate: now);
                            if (pickedDate != null) {
                              setState(() {
                                dob = pickedDate.millisecondsSinceEpoch
                                    .toString();
                                dobController.text = DateFormat.getDate(
                                    context: context,
                                    date: pickedDate.millisecondsSinceEpoch
                                        .toString());
                              });
                            }
                          },
                          labelText: 'DOB',
                          controller: dobController,
                          hintText: "Enter Date of birth",
                          type: 'DOB'),
                      CustomTextField(
                          textInputType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          labelText: 'Weight',
                          controller: weightController,
                          hintText: isMale
                              ? "How much does he weigh"
                              : "How much does she weigh",
                          type: 'weight'),
                      Row(
                        children: [
                          const Spacer(),
                          Checkbox(
                            value: isVaccinated,
                            onChanged: (value) {
                              setState(() {
                                isVaccinated = value!;
                              });
                            },
                          ),
                          const Text(
                            'Vaccinated',
                            style: TextStyle(color: Colors.brown),
                          ),
                          const SizedBox(
                            width: 18,
                          )
                        ],
                      ),
                      isVaccinated
                          ? CustomTextField(
                              readOnly: true,
                              onTap: () async {
                                DateTime now = DateTime.now();
                                if (dob.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Dob not picked'),
                                        content: const Text(
                                            'Please select Date of birth first!'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('OK'))
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  final pickedDate = await showDatePicker(
                                      context: context,
                                      firstDate:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(dob)),
                                      lastDate: now);
                                  if (pickedDate != null) {
                                    setState(() {
                                      vaccinatedDate = pickedDate
                                          .millisecondsSinceEpoch
                                          .toString();
                                      lastVaccinatedController.text =
                                          DateFormat.getDate(
                                              context: context,
                                              date: pickedDate
                                                  .millisecondsSinceEpoch
                                                  .toString());
                                    });
                                  }
                                }
                              },
                              controller: lastVaccinatedController,
                              hintText: 'Last Vaccinated date',
                              type: 'vaccination')
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 15),
                        child: DropdownMenu(
                            label: const Text('Select Category'),
                            onSelected: (value) {
                              selectedCategory =
                                  GlobalVariables.categories.firstWhere(
                                (element) => element.name == value!,
                              );
                            },
                            width: double.infinity,
                            dropdownMenuEntries: categories.map(
                              (category) {
                                return DropdownMenuEntry(
                                    label: category.name, value: category.name);
                              },
                            ).toList()),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Enter Category'),
                                      content: CustomTextField(
                                          textCapitalization:
                                              TextCapitalization.words,
                                          controller: categoryController,
                                          hintText: 'Request a new category',
                                          type: 'category'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              if (categoryController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                FirebaseServices.firestore
                                                    .collection(FirebaseServices
                                                        .categoryRequestsCollection)
                                                    .add({
                                                  'request': categoryController
                                                      .text
                                                      .trim(),
                                                  'user': GlobalVariables
                                                      .currentUser
                                                      .toJson()
                                                });
                                                categoryController.clear();
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Thank You😍'),
                                                    content: const Text(
                                                        'Thank you for requesting new category😁, it will be available soon!✨'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("OK"))
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Request')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel')),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text('Request new category'))
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextField(
                          textInputType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
                          ],
                          labelText: 'Contact Number',
                          controller: contactNumController,
                          hintText: "Your Contact number",
                          type: 'phone Number'),
                    ],
                  ),
                ),
                SizedBox(
                  height: mq.height * .01,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: LoginButton(
                    onTap: () async {
                      if (_formKey.currentState!.validate() &&
                          imageAdded &&
                          selectedCategory != null) {
                        setState(() {
                          isUploading = true;
                        });
                        await uploadImages();
                        context.read<GlobalVariables>().addPet(
                            name: nameController.text.trim(),
                            images: imageUrls,
                            isMale: isMale,
                            dob: dob,
                            category: selectedCategory!.id!,
                            contactNumber: contactNumController.text.trim(),
                            description: descriptionController.text.trim(),
                            user: owner,
                            location: owner.location!,
                            latitude: owner.latitude!,
                            longitude: owner.longitude!,
                            weight: double.parse(weightController.text.trim()),
                            status: 'Requested',
                            createdAt: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            breed: breedController.text.trim());
                        FirebaseServices.createPet(
                            name: nameController.text.trim(),
                            images: imageUrls,
                            isMale: isMale,
                            dob: dob,
                            category: selectedCategory!.id!,
                            contactNumber: contactNumController.text.trim(),
                            description: descriptionController.text.trim(),
                            user: owner,
                            location: owner.location!,
                            latitude: owner.latitude!,
                            longitude: owner.longitude!,
                            weight: double.parse(weightController.text.trim()),
                            status: 'Requested',
                            createdAt: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            breed: breedController.text.trim());
                        NotificationServices.newPetAdded(PetModel(
                          id: '${owner.id!}-${DateTime.now().millisecondsSinceEpoch}',
                            lastVaccinated: vaccinatedDate,
                            latitude: owner.latitude!,
                            location: owner.location!,
                            longitude: owner.longitude!,
                            name: nameController.text.trim(),
                            images: imageUrls,
                            isMale: isMale,
                            dob: dob,
                            category: selectedCategory!.id!,
                            contactNumber: contactNumController.text.trim(),
                            description: descriptionController.text.trim(),
                            ownerId: owner.id!,
                            weight: double.parse(weightController.text.trim()),
                            status: 'Requested',
                            createdAt: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            breed: breedController.text.trim()));
                        setState(() {
                          isUploading = false;
                        });
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text('Pet added Successfully'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'))
                              ],
                            );
                          },
                        );
                      } else if (!imageAdded) {
                        showAlert(
                            title: 'Image not added',
                            content: 'Please add images to continue adding');
                      } else if (selectedCategory == null) {
                        showAlert(
                            title: 'Category not selected',
                            content:
                                'Please selected corresponding category to continue adding your pet');
                      } else if (isVaccinated &&
                          lastVaccinatedController.text.trim().isEmpty) {
                        showAlert(
                            title: 'Vaccinated Date',
                            content:
                                'Please enter last vaccinated date to continue adding your pet. Otherwise please unselect vaccinated checkbox');
                      } else if (contactNumController.text.length != 10) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Invalid Phone Number"),
                                content: const Text(
                                    "Please enter a valid Phone number to continue."),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      }
                    },
                    child: const Text(
                      'Add my pet',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height * .05,
                )
              ],
            ),
          ),
        ),
        isUploading
            ? Container(
                height: mq.height,
                width: mq.width,
                color: Colors.black38,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: AppStyle.mainColor,
                ),
              )
            : const SizedBox()
      ],
    );
  }

  Future showAlert({required String title, required String content}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}
