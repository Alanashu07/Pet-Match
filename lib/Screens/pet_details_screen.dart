import 'package:flutter/material.dart';

import '../Constants/global_variables.dart';
import '../Models/pet_model.dart';
import 'my_pets_details.dart';
import 'others_pet_details.dart';

class PetDetailsScreen extends StatelessWidget {
  final PetModel pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return pet.ownerId == GlobalVariables.currentUser.id ? Container(
        color: Colors.white,
        child: MyPetsDetails(pet: pet,)) : Container(
        color: Colors.white,
        child: OthersPetDetails(pet: pet));
  }
}
