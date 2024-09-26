import 'dart:ui';

import 'category_model.dart';

class PetModel {
  late String? id;
  late String name;
  late List<String> images;
  late String? location;
  late double? latitude;
  late double? longitude;
  late bool isMale;
  late String dob;
  late String ownerId;
  late String category;
  late double weight;
  late String description;
  late String contactNumber;
  late String status;
  late String createdAt;
  late String? lastVaccinated;
  late String breed;

  PetModel({
    this.id,
    required this.name,
    required this.images,
    this.location,
    this.latitude,
    this.longitude,
    required this.isMale,
    required this.dob,
    required this.category,
    required this.contactNumber,
    required this.description,
    required this.ownerId,
    required this.weight,
    required this.status,
    required this.createdAt,
    this.lastVaccinated,
    required this.breed
  });

  PetModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    images = json['images'].cast<String>() ?? [];
    location = json['location'] ?? '';
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    isMale = json['isMale'] ?? true;
    dob = json['dob'] ?? '';
    ownerId = json['ownerId'] ?? '';
    category = json['category'] ?? '';
    weight = json['weight'] ?? 0.0;
    description = json['description'] ?? '';
    contactNumber = json['contactNumber'] ?? '';
    status = json['status'] ?? '';
    createdAt = json['createdAt'] ?? '';
    lastVaccinated = json['lastVaccinated'] ?? '';
    breed = json['breed'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['images'] = images;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['isMale'] = isMale;
    data['dob'] = dob;
    data['ownerId'] = ownerId;
    data['category'] = category;
    data['weight'] = weight;
    data['description'] = description;
    data['contactNumber'] = contactNumber;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['lastVaccinated'] = lastVaccinated;
    data['breed'] = breed;
    return data;
  }
}