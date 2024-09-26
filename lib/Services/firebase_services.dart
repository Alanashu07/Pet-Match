import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:pet_match/Models/rating_model.dart';
import 'package:pet_match/Models/user_model.dart' as user_model;
import '../Models/message_model.dart';

class FirebaseServices extends ChangeNotifier {
  static String usersCollection = 'users';
  static String petsCollection = 'pets';
  static String accessoriesCollection = 'accessories';
  static String ratingsCollection = 'ratings';
  static String messagesCollection = 'messages';
  static String categoriesCollection = 'categories';
  static String categoryRequestsCollection = 'category-requests';
  static String reportsCollection = 'reports';

  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<bool> userExists() async {
    return (await firestore
            .collection(usersCollection)
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((value) {
      if (value != null) {
        firestore.collection(usersCollection).doc(auth.currentUser!.uid).update({
          'token': value
        });
        GlobalVariables.currentUser.token = value;
      }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection(usersCollection)
        .doc(auth.currentUser!.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection(usersCollection)
        .where('id', whereIn: userIds)
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      {required user_model.User chatUser}) async {
    await firestore
        .collection(usersCollection)
        .doc(auth.currentUser!.uid)
        .collection('my_users')
        .doc(chatUser.id)
        .set({});
    await firestore
        .collection(usersCollection)
        .doc(chatUser.id)
        .collection('my_users')
        .doc(auth.currentUser!.uid)
        .set({});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(user_model.User chatUser) {
    return firestore
        .collection(usersCollection)
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore
        .collection(usersCollection)
        .doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'token': GlobalVariables.currentUser.token
    });
  }

  static String getConversationId(String id) =>
      auth.currentUser!.uid.hashCode <= id.hashCode
          ? '${auth.currentUser!.uid}_$id'
          : '${id}_${auth.currentUser!.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      user_model.User user) {
    return firestore
        .collection('$messagesCollection/${getConversationId(user.id!)}/chats/')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(user_model.User user) {
    return firestore
        .collection('$messagesCollection/${getConversationId(user.id!)}/chats/').orderBy('sentAt', descending: true).limit(1)
        .snapshots();
  }

  static Future<void> sendMessage(
      user_model.User chatUser, Message message) async {
    final ref = firestore.collection(
        '$messagesCollection/${getConversationId(chatUser.id!)}/chats/');
    await ref.doc(message.id).set(message.toJson());
  }

  static Future<void> updateReadStatus(Message message) async {
    firestore
        .collection(
            '$messagesCollection/${getConversationId(message.sender)}/chats/')
        .doc(message.id)
        .update({
      'readAt': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  static Future<void> createUser() async {
    final user = user_model.User(
      notifications: [],
      password: '',
      id: auth.currentUser!.uid,
      name: auth.currentUser!.displayName ?? '',
      phoneNumber: auth.currentUser!.phoneNumber ?? '',
      email: auth.currentUser!.email ?? '',
      location: '',
      latitude: 0,
      longitude: 0,
      pets: [],
      favouritePets: [],
      adoptedPets: [],
      image: auth.currentUser!.photoURL ?? '',
      isOnline: false,
      joinedOn: DateTime.now().millisecondsSinceEpoch.toString(),
      lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'user',
      token: '',
    );

    return await firestore
        .collection(usersCollection)
        .doc(auth.currentUser!.uid)
        .set(user.toJson());
  }

  static Future<void> updateUser(
      {required user_model.User user,
      required String name,
      required String phoneNumber,
      required String newImage}) async {
    final userToEdit = user_model.User(
      notifications: user.notifications,
      password: user.password,
      id: user.id,
      name: name,
      phoneNumber: phoneNumber,
      email: user.email,
      location: user.location,
      latitude: user.latitude,
      longitude: user.longitude,
      pets: user.pets,
      favouritePets: user.favouritePets,
      adoptedPets: user.adoptedPets,
      image: newImage,
      isOnline: user.isOnline,
      joinedOn: user.joinedOn,
      lastActive: user.lastActive,
      type: user.type,
      token: user.token,
    );

    return await firestore
        .collection(usersCollection)
        .doc(user.id)
        .update(userToEdit.toJson());
  }

  static Future<void> userWithEmail(
      {required String name,
      required String password,
      required String email,
      String? phoneNumber,
      required String image}) async {
    final user = user_model.User(
      id: auth.currentUser!.uid,
      name: name,
      notifications: [],
      phoneNumber: phoneNumber ?? '',
      email: auth.currentUser!.email ?? '',
      password: password,
      location: '',
      latitude: 0,
      longitude: 0,
      pets: [],
      favouritePets: [],
      adoptedPets: [],
      image: image,
      isOnline: false,
      joinedOn: DateTime.now().millisecondsSinceEpoch.toString(),
      lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'user',
      token: '',
    );
    return await firestore
        .collection(usersCollection)
        .doc(auth.currentUser!.uid)
        .set(user.toJson());
  }

  static Future<void> createPet(
      {required String name,
      required List<String> images,
      required bool isMale,
      required String dob,
      required String category,
      required String contactNumber,
      required String description,
      required user_model.User user,
      String? lastVaccinated,
      required String location,
      required double latitude,
      required double longitude,
      required double weight,
      required String status,
      required String createdAt,
      required String breed}) async {
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
    return await firestore
        .collection(petsCollection)
        .doc('${user.id!}-$time')
        .set(pet.toJson());
  }

  static Future<void> updatePet({
    required String name,
    required PetModel pet,
    required String description,
    String? lastVaccinated,
    required double weight,
  }) async {
    final updatePet = PetModel(
        name: name,
        images: pet.images,
        isMale: pet.isMale,
        dob: pet.dob,
        category: pet.category,
        contactNumber: pet.contactNumber,
        description: description,
        ownerId: pet.ownerId,
        weight: weight,
        status: pet.status,
        createdAt: pet.createdAt,
        breed: pet.breed,
        id: pet.id,
        lastVaccinated: lastVaccinated ?? pet.lastVaccinated,
        latitude: pet.latitude,
        location: pet.location,
        longitude: pet.longitude);
    return await firestore
        .collection(petsCollection)
        .doc(pet.id)
        .update(updatePet.toJson());
  }

  static Future<void> addRating(
      {required double rating, required String description}) async {
    final ratingModel = RatingModel(
        rating: rating,
        description: description,
        userId: GlobalVariables.currentUser.id!,
        time: DateTime.now().millisecondsSinceEpoch.toString(),
        id: '${GlobalVariables.currentUser.id!}-${DateTime.now().millisecondsSinceEpoch.toString()}');
    return await firestore
        .collection(ratingsCollection)
        .doc(
            '${GlobalVariables.currentUser.id!}-${DateTime.now().millisecondsSinceEpoch.toString()}')
        .set(ratingModel.toJson());
  }
}
