import 'package:pet_match/Models/notification_model.dart';

class User {
  late String? id;
  late String name;
  late String phoneNumber;
  late String email;
  late String? password;
  late String? location;
  late double? latitude;
  late double? longitude;
  late List<NotificationModel> notifications;
  late List<String>? pets;
  late List<String> favouritePets;
  late List<String> adoptedPets;
  late String? image;
  late bool isOnline;
  late String joinedOn;
  late String lastActive;
  late String type;
  late String? token;

  User(
      {this.id,
        required this.name,
        required this.phoneNumber,
        required this.email,
        this.password,
        this.location,
        this.latitude,
        this.longitude,
        required this.notifications,
        this.pets,
        this.isOnline = false,
        required this.favouritePets,
        required this.adoptedPets,
        required this.type,
        this.token,
        this.image,
        required this.joinedOn,
        required this.lastActive});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    email = json['email'] ?? '';
    password = json['password'] ?? '';
    location = json['location'] ?? '';
    latitude = json['latitude'] ?? 0;
    longitude = json['longitude'] ?? 0;
    pets = json['pets'].cast<String>() ?? [];
    notifications = (json['notifications'] as List).map((n) => NotificationModel.fromJson(n),).toList();
    favouritePets = json['favouritePets'].cast<String>() ?? [];
    adoptedPets = json['adoptedPets'].cast<String>() ?? [];
    image = json['image'] ?? '';
    isOnline = json['isOnline'] ?? false;
    joinedOn = json['joinedOn'] ?? '';
    lastActive = json['lastActive'] ?? '';
    type = json['type'] ?? '';
    token = json['token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['email'] = email;
    data['password'] = password;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['pets'] = pets;
    data['favouritePets'] = favouritePets;
    data['notifications'] = notifications;
    data['adoptedPets'] = adoptedPets;
    data['image'] = image;
    data['isOnline'] = isOnline;
    data['joinedOn'] = joinedOn;
    data['lastActive'] = lastActive;
    data['type'] = type;
    data['token'] = token;
    return data;
  }
}
