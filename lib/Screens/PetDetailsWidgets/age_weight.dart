import 'package:flutter/material.dart';

import '../../Models/pet_model.dart';
import '../../Styles/app_style.dart';
import '../../date_format.dart';

class AgeWeight extends StatelessWidget {
  final PetModel pet;
  const AgeWeight({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyle.mainColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyle.mainColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Age", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Text(DateFormat.getAge(context: context, dob: pet.dob), style: const TextStyle(color: Colors.black54,  fontSize: 13),)
              ],
            ),
          ),
          Container(
            height: 40,
            width: 2,
            color: AppStyle.mainColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Weight", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  Text('${pet.weight} Kgs', style: const TextStyle(color: Colors.black54,  fontSize: 13),)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
