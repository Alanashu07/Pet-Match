import 'package:flutter/material.dart';

import '../../Constants/global_variables.dart';
import '../../Models/pet_model.dart';
import '../../date_format.dart';

class OwnerHeader extends StatelessWidget {
  final PetModel pet;
  const OwnerHeader({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final owner = GlobalVariables.users.firstWhere((element) => element.id == pet.ownerId,);
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(owner.image ?? GlobalVariables.errorImage),
      ),
      title: Text(owner.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      subtitle: const Text("Pet Owner", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16),),
      trailing: Text(DateFormat.getCreatedTime(context: context, time: pet.createdAt)),
    );
  }
}
