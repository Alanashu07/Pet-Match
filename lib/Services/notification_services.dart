import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Models/notification_model.dart';
import 'package:pet_match/Services/firebase_services.dart';
import '../Models/category_model.dart';
import '../Models/pet_model.dart';
import '../Models/user_model.dart';

class NotificationServices extends ChangeNotifier {

  static Future<void> newPetAdded(PetModel pet) async {
    final users = GlobalVariables.users.where((element) =>
    element.id != GlobalVariables.currentUser.id,).toList();
    for (var user in users) {
      NotificationModel notification = NotificationModel(
          type: pet.id!,
          isRead: false,
          senderId: GlobalVariables.currentUser.id!,
          id:
          '${GlobalVariables.currentUser.id}-${user.id}-${DateTime
              .now()
              .millisecondsSinceEpoch}',
          receiverId: user.id!,
          title: "Hooray!!!!✨✨ New Pet Arrived",
          page: 'pet',
          image: pet.images[0],
          message:
          "${user.name} has added a new pet ${pet
              .name}😍, explore app to find the pet! or open here.",
          sendAt: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString());
      await FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(user.id)
          .update({
        'notifications': FieldValue.arrayUnion([notification.toJson()])
      });
    }
  }

  static Future<void> favoritePetAdopted(
      {required PetModel pet, required User adoptedUser}) async {
    List<User> favoriteUsers = GlobalVariables.users.where((element) =>
    element.favouritePets.contains(pet.id) && element.id != adoptedUser.id,)
        .toList();
    for (var user in favoriteUsers) {
      NotificationModel notification = NotificationModel(
          type: pet.id!,
          senderId: GlobalVariables.currentUser.id!,
          id:
          '${GlobalVariables.currentUser.id}-${user.id}-${DateTime
              .now()
              .millisecondsSinceEpoch}',
          isRead: false,
          receiverId: user.id!,
          title: "Favorite Pet Adopted",
          page: 'pet',
          image: pet.images[0],
          message:
          "${adoptedUser.name} has adopted ${pet
              .name}, explore the app and find other companions.",
          sendAt: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString());
      await FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(user.id)
          .update({
        'notifications': FieldValue.arrayUnion([notification.toJson()]),
      });
    }
  }

  static Future<void> favoritePetGiven(
      {required PetModel pet, required User givenUser}) async {
    List<User> favoriteUsers = GlobalVariables.users.where((element) =>
    element.favouritePets.contains(pet.id) && element.id != givenUser.id,)
        .toList();
    for (var user in favoriteUsers) {
      NotificationModel notification = NotificationModel(
          type: pet.id!,
          senderId: GlobalVariables.currentUser.id!,
          id:
          '${GlobalVariables.currentUser.id}-${user.id}-${DateTime
              .now()
              .millisecondsSinceEpoch}',
          receiverId: user.id!,
          isRead: false,
          title: "Favorite Pet Given",
          page: 'pet',
          image: pet.images[0],
          message:
          "${GlobalVariables.currentUser.name} has given ${pet
              .name} to ${givenUser
              .name}, explore the app and find other companions.",
          sendAt: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString());
      await FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(user.id)
          .update({
        'notifications': FieldValue.arrayUnion([notification.toJson()]),
      });
    }
  }

  static Future<void> requestedCategoryAdded(
      {required CategoryModel category, required User requestedUser}) async {
    NotificationModel notification = NotificationModel(
        senderId: GlobalVariables.currentUser.id!,
        id: '${GlobalVariables.currentUser.id}-${requestedUser.id}-${DateTime
            .now()
            .millisecondsSinceEpoch}',
        receiverId: requestedUser.id!,
        title: "Thank you for your collaboration💕✨",
        page: 'categories',
        isRead: false,
        type: category.id!,
        image: category.image,
        message: "Your requested category ${category.name} has been added to the app. Thank You!✨💕",
        sendAt: DateTime.now().millisecondsSinceEpoch.toString());
    await FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(requestedUser.id).update({
      'notifications': FieldValue.arrayUnion([notification.toJson()])
    });
  }

  static Future<void> adoptionCancelled({required PetModel pet, required User adoptedUser}) async {
    NotificationModel notification = NotificationModel(
        senderId: GlobalVariables.currentUser.id!,
        isRead: false,
        id: '${GlobalVariables.currentUser.id}-${adoptedUser.id}-${DateTime
            .now()
            .millisecondsSinceEpoch}',
        receiverId: adoptedUser.id!,
        title: "Oops!!🙁, Adoption cancelled",
        page: 'pet',
        type: pet.id!,
        image: pet.images[0],
        message: "${GlobalVariables.currentUser.name} has cancelled their adoption to give you ${pet.name}😞",
        sendAt: DateTime.now().millisecondsSinceEpoch.toString());
    await FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(adoptedUser.id).update({
      'notifications': FieldValue.arrayUnion([notification.toJson()])
    });
  }

  static Future<void> newCategoryAdded(CategoryModel category) async {
    final users = GlobalVariables.users.where((element) =>
    element.id != GlobalVariables.currentUser.id,).toList();
    for(var user in users) {
      NotificationModel notification = NotificationModel(
          senderId: GlobalVariables.currentUser.id!,
          isRead: false,
          id: '${GlobalVariables.currentUser.id}-${user.id}-${DateTime
              .now()
              .millisecondsSinceEpoch}',
          receiverId: user.id!,
          title: "Hooray!!!✨ New Category Added",
          page: 'categories',
          type: category.id!,
          image: category.image,
          message: "A new category ${category.name} has been added to the app. Hope you utilize it.😊",
          sendAt: DateTime.now().millisecondsSinceEpoch.toString());
      await FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(user.id).update({
        'notifications': FieldValue.arrayUnion([notification.toJson()])
      });
    }
  }

}
