import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../../Models/pet_model.dart';
import '../../../Styles/app_style.dart';
import '../../../date_format.dart';
import '../../pet_details_screen.dart';

class AdoptedPetCard extends StatelessWidget {
  final PetModel pet;
  final double padding;
  final double height;
  final double width;
  final double borderRadius;

  const AdoptedPetCard(
      {super.key,
      required this.pet,
      this.padding = 16,
      this.height = 100,
      this.width = double.infinity,
      this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  child: PetDetailsScreen(pet: pet),
                  type: PageTransitionType.bottomToTop,
                  ));
        },
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: pet.status == 'Given' ? AppStyle.accentColor.withOpacity(0.1) : AppStyle.mainColor.withOpacity(0.1),
              border: Border.all(color: pet.status == 'Given' ? AppStyle.accentColor : AppStyle.mainColor)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(pet.images[0]),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      pet.breed,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat.getCreatedTime(
                      context: context, time: pet.createdAt)),
                  pet.status == 'Given' ? const Text("Pending...", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),) : const SizedBox()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
