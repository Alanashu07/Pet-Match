import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:pet_match/Services/notification_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/accessory_model.dart';
import '../Models/category_model.dart';
import '../Models/conversation_model.dart';
import '../Models/message_model.dart';
import '../Models/notification_model.dart';
import '../Models/pet_model.dart';
import '../Models/rating_model.dart';
import '../Models/user_model.dart';
import '../Services/location_services.dart';
import '../Styles/app_style.dart';
import '../Widgets/custom_text_field.dart';

class GlobalVariables extends ChangeNotifier {
  static Future<Placemark> getPosition(BuildContext context, VoidCallback onFailed) async {
    LocationServices locationServices = LocationServices();
    try {
      Position position = await locationServices.getCurrentPosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      return place;
    } catch (e) {
      onFailed();
      return Future.error(e);
    }
  }

  static int sortingIndex = 0;

  int get sortIndex => sortingIndex;

  void incrementSortIndex() {
    if(sortingIndex == 13) {
      sortingIndex = 0;
    } else{
      sortingIndex++;
    }
    notifyListeners();
  }

  void setSortIndex(int index) {
    sortingIndex = index;
    notifyListeners();
  }

  void sortPets(List<PetModel> pets) {
    if (sortingIndex == 0) {
      pets.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortingIndex == 1) {
      pets.sort((a, b) => b.name.compareTo(a.name));
    } else if (sortingIndex == 2) {
      pets.sort((a, b) => a.dob.compareTo(b.dob));
    } else if (sortingIndex == 3) {
      pets.sort((a, b) => b.dob.compareTo(a.dob));
    } else if (sortingIndex == 4) {
      pets.sort((a, b) => a.breed.compareTo(b.breed));
    } else if (sortingIndex == 5) {
      pets.sort((a, b) => b.breed.compareTo(a.breed));
    } else if (sortingIndex == 6) {
      pets.sort((a, b) => a.weight.compareTo(b.weight));
    } else if (sortingIndex == 7) {
      pets.sort((a, b) => b.weight.compareTo(a.weight));
    } else if (sortingIndex == 8) {
      pets.sort((a, b) => a.lastVaccinated!.compareTo(b.lastVaccinated!));
    } else if (sortingIndex == 9) {
      pets.sort((a, b) => b.lastVaccinated!.compareTo(a.lastVaccinated!));
    } else if (sortingIndex == 10) {
      pets.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sortingIndex == 11) {
      pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortingIndex == 12) {
      pets.sort((a, b) {
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
    } else if (sortingIndex == 13) {
      pets.sort((b, a) {
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
    notifyListeners();
  }

  void addPetImages({required List<XFile> images, required PetModel pet}) {
    final paths = images.map((image) => image.path).toList();
    pet.images.addAll(paths);
    notifyListeners();
  }

  void updatePetStatus({required PetModel pet, required String newStatus}) {
    FirebaseServices.firestore
        .collection(FirebaseServices.petsCollection)
        .doc(pet.id)
        .update({'status': newStatus});
    pet.status = newStatus;
    notifyListeners();
  }

  void giveToAdopt({required String petId, required User user}) {
    final pet = pets.firstWhere((element) => element.id == petId,);
    FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(user.id).update({
      'adoptedPets': FieldValue.arrayUnion([petId])
    });
    NotificationServices.favoritePetGiven(pet: pet, givenUser: user);
    user.adoptedPets.add(petId);
    notifyListeners();
  }

  void cancelAdoption({required PetModel pet}) {
    final user = users.firstWhere((element) => element.adoptedPets.contains(pet.id),);
    FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(user.id).update({
      'adoptedPets': FieldValue.arrayRemove([pet.id])
    });
    user.adoptedPets.remove(pet.id);
    FirebaseServices.firestore
        .collection(FirebaseServices.petsCollection)
        .doc(pet.id)
        .update({'status': 'Approved'});
    NotificationServices.adoptionCancelled(pet: pet, adoptedUser: user);
    pet.status = 'Approved';
    notifyListeners();
  }

  void updateUser(
      {
      required String name,
      required String phoneNumber,
      required String newImage}) {
    currentUser.name = name;
    currentUser.phoneNumber = phoneNumber;
    currentUser.image = newImage;
    notifyListeners();
  }

  void updateUserType({required String newType}) {
    User user = currentUser;
    user.type = newType;
    FirebaseServices.firestore
        .collection(FirebaseServices.usersCollection)
        .doc(user.id)
        .update({'type': newType});
    notifyListeners();
  }

  static editDialog({
    required BuildContext context,
    required PetModel pet,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController weightController,
    required TextEditingController lastVaccinatedController,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        nameController.text = pet.name;
        descriptionController.text = pet.description;
        weightController.text = pet.weight.toString();
        lastVaccinatedController.text = pet.lastVaccinated ?? '';
        return AlertDialog(
          title: const Text('Edit your pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(flex: 1, child: Text("Name")),
                  const Text(":"),
                  Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: nameController,
                        hintText: 'Name of your pet',
                        type: 'name',
                      )),
                ],
              ),
              Row(
                children: [
                  const Expanded(flex: 1, child: Text("Description")),
                  const Text(":"),
                  Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: descriptionController,
                        hintText: 'Description of your pet',
                        type: 'description',
                      )),
                ],
              ),
              Row(
                children: [
                  const Expanded(flex: 1, child: Text("Weight")),
                  const Text(":"),
                  Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: weightController,
                        hintText: 'Weight of your pet',
                        type: 'weight',
                      )),
                ],
              ),
              Row(
                children: [
                  const Expanded(flex: 1, child: Text("Last Vaccinated")),
                  const Text(":"),
                  Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: lastVaccinatedController,
                        hintText: 'Last Vaccinated Date',
                        type: 'last Vaccinated',
                      )),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  context.read<GlobalVariables>().updatePet(
                      pet: pet,
                      name: nameController.text,
                      weight: double.parse(weightController.text),
                      description: descriptionController.text,
                      lastVaccinated: lastVaccinatedController.text);
                  Navigator.pop(context);
                },
                child: const Text('Submit')),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  void updatePet(
      {required PetModel pet,
      required String name,
      required double weight,
      required String description,
      required String lastVaccinated}) {
    pet.name = name;
    pet.weight = weight;
    pet.description = description;
    pet.lastVaccinated = lastVaccinated;
    notifyListeners();
  }

  static List<RatingModel> ratings = [];

  static String errorImage =
      'https://wallup.net/wp-content/uploads/2018/10/07/8076-wall1831412-animals-dogs-puppies-pets-748x468.jpg';

  void deletePetImage({required PetModel pet, required String image}) {
    FirebaseServices.firestore
        .collection(FirebaseServices.petsCollection)
        .doc(pet.id)
        .update({
      'images': FieldValue.arrayRemove([image])
    });
    pet.images.remove(image);
    notifyListeners();
  }

  void deletePet({required PetModel pet}) {
    FirebaseServices.firestore
        .collection(FirebaseServices.petsCollection)
        .doc(pet.id)
        .delete();
    pets.remove(pet);
    FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(currentUser.id).update({
      'pets': FieldValue.arrayRemove([pet.id])
    });
    currentUser.pets!.remove(pet.id);
    notifyListeners();
  }

  void addToFavorite({required String petId}) {
    List<String> favPets = currentUser.favouritePets;
    if (currentUser.favouritePets.contains(petId)) {
      favPets.remove(petId);
      favPets = favPets.toSet().toList();
      FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(currentUser.id)
          .update({
        'favouritePets': favPets
      });
      currentUser.favouritePets = favPets;
    } else {
      favPets.add(petId);
      favPets = favPets.toSet().toList();
      FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(currentUser.id)
          .update({
        'favouritePets': favPets
      });
      currentUser.favouritePets = favPets;
    }
    notifyListeners();
  }


  void setRead(NotificationModel notification) {
    List<NotificationModel> updatedNotifications = [];
    for(var n in currentUser.notifications) {
      if(n.id == notification.id) {
        n.isRead = true;
      }
      updatedNotifications.add(n);
    }
    updatedNotifications = updatedNotifications.toSet().toList();
    FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(currentUser.id).update({
      'notifications': updatedNotifications.map((e) => e.toJson()).toList()
    });
    notification.isRead = true;
    notifyListeners();
  }

  static int getRandomColor() {
    Random random = Random();
    return random.nextInt(AppStyle.categoryColor.length);
  }

  static Future<void> getCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseServices.firestore
          .collection(FirebaseServices.categoriesCollection)
          .get();
      categories = snapshot.docs
          .map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
      categories.removeWhere((category) => restrictedCategories.contains(category.id),);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static List<String> restrictedCategories = [];

  static Future loadRestricted () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    restrictedCategories = prefs.getStringList('category') ?? [];
    restrictedPets = prefs.getStringList('pets') ?? [];
  }

  void excludeCategory(String category) async {
    restrictedCategories.add(category);
    restrictedPets.addAll(pets.where((element) => element.category == category,).map((e) => e.id!,));
    restrictedPets = restrictedPets.toSet().toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('category', restrictedCategories);
    await prefs.setStringList('pets', restrictedPets);
    notifyListeners();
  }

  void excludePet(String pet) async {
    restrictedPets.add(pet);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pets', restrictedPets);
    notifyListeners();
  }

  void includePet(String pet) async {
    restrictedPets.remove(pet);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pets', restrictedPets);
    notifyListeners();
  }

  void includeCategory(String category) async {
    List<PetModel> categoryPets = pets.where((element) => restrictedCategories.contains(element.category),).toList();
    for(var pet in categoryPets) {
      for(var id in restrictedPets) {
        if(id == pet.id) {
          restrictedPets.remove(id);
          break;
        }
      }
    }
    restrictedCategories.remove(category);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('category', restrictedCategories);
    await prefs.setStringList('pets', restrictedPets);
    notifyListeners();
  }

  void emptyRestriction() async {
    restrictedPets = [];
    restrictedCategories = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('category', restrictedCategories);
    await prefs.setStringList('pets', restrictedPets);
    notifyListeners();
  }

  List<String> get excludedCategories => restrictedCategories;

  static List<CategoryModel> categories = [];

  List<PetModel> get approvedPets =>
      pets.where((pet) => pet.status == 'Approved' && !restrictedPets.contains(pet.id)).toList();

  List<PetModel> get allPets => pets.where((pet) => !restrictedPets.contains(pet.id),).toList();

  List<PetModel> get everyPet => pets;

  void addPet(
      {required String name,
      required List<String> images,
      required bool isMale,
      required String dob,
      required String category,
      required String contactNumber,
      required String description,
      required User user,
      String? lastVaccinated,
      required String location,
      required double latitude,
      required double longitude,
      required double weight,
      required String status,
      required String createdAt,
      required String breed}) {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    final pet = PetModel(
        name: name,
        images: images,
        isMale: isMale,
        dob: dob,
        category: category,
        contactNumber: contactNumber,
        description: description,
        ownerId: user.id!,
        weight: weight,
        status: status,
        createdAt: createdAt,
        breed: breed,
        id: '${user.id!}-$time',
        lastVaccinated: lastVaccinated ?? '',
        latitude: latitude,
        location: location,
        longitude: longitude);
    pets.add(pet);
    notifyListeners();
  }

  static Future<void> getPets() async {
    try {
      QuerySnapshot snapshot = await FirebaseServices.firestore
          .collection(FirebaseServices.petsCollection)
          .get();
      pets = snapshot.docs
          .map((e) => PetModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static List<PetModel> pets = [];

  static List<Message> messages = [];

  List<Message> get allMessages => messages;

  static Future<void> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .get();
      users = snapshot.docs
          .map((e) => User.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void setUserLocation({required double latitude, required double longitude, required String location}) {
    user.location = location;
    user.latitude = latitude;
    user.longitude = longitude;
    notifyListeners();
  }

  static List<User> users = [];

  List<User> get allUsers => users;

  static Future<User?> getCurrentUser() async {
    if (FirebaseServices.auth.currentUser != null) {
      final userData = await FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(FirebaseServices.auth.currentUser!.uid)
          .get();
      User user = User.fromJson(userData.data()!);
      currentUser = user;
      FirebaseServices.getFirebaseMessagingToken();
      return user;
    } else {
      return null;
    }
  }

  static late User currentUser;

  User get user => currentUser;

  static List<Accessory> accessories = [];

  static Future<void> getAllAccessories() async {
    try {
      QuerySnapshot snapshot = await FirebaseServices.firestore
          .collection(FirebaseServices.accessoriesCollection)
          .get();
      accessories = snapshot.docs
          .map((e) => Accessory.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  List<Accessory> get allAccessories => accessories;

  static List<ConversationModel> conversations = [
    ConversationModel(
        senderId: 'Es4WlEj2jXTysaBSOkQRZm36GFs1',
        receiverId: currentUser.id!,
        lastMessage: "Nothing much",
        petId: pets[0].id!,
        lastMessageTime: "1726466164724"),
    ConversationModel(
        senderId: 'TYY7Fj47uEa9kmX5umZn1x7ciEh2',
        receiverId: currentUser.id!,
        lastMessage: "Nothing much",
        petId: pets[0].id!,
        lastMessageTime: "1726338907952"),
  ];

  static List<String> restrictedPets = [];

  List<String> get excludedPets => restrictedPets;
}
