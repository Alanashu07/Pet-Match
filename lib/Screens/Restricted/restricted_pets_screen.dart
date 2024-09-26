import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:provider/provider.dart';
import '../../Styles/app_style.dart';
import '../../date_format.dart';

class RestrictedPetsScreen extends StatelessWidget {
  const RestrictedPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final restrictedPets = context.watch<GlobalVariables>().everyPet.where((element) => context.watch<GlobalVariables>().excludedPets.contains(element.id!),).toList();
    return Container(
        color: Colors.white,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: const Icon(CupertinoIcons.back)),
            title: const Text("Restricted Pets"),
          ),
          body: restrictedPets.isNotEmpty ? ListView.separated(itemBuilder: (context, index) {
            final pet = restrictedPets[index];
            return listItem(context: context, pet: pet).animate().fade();
          }, separatorBuilder: (context, index) => const SizedBox(height: 10,), itemCount: restrictedPets.length) : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/adopted-cat.png', color: AppStyle.accentColor, scale: 5,),
                SizedBox(height: mq.height*.02,),
                Text("You haven't excluded any pets yet!", style: TextStyle(color: AppStyle.accentColor, fontSize: 20),),
              ],
            ),
          ),
        ));
  }

  Widget listItem({required BuildContext context, required PetModel pet}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {

        },
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppStyle.mainColor.withOpacity(0.1),
              border: Border.all(color: AppStyle.mainColor)),
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
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat.getCreatedTime(
                      context: context, time: pet.createdAt)),
                  IconButton(onPressed: (){
                    context.read<GlobalVariables>().includePet(pet.id!);
                  }, icon: const Icon(Icons.close))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
