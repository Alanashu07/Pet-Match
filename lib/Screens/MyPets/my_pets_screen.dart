import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Constants/global_variables.dart';
import '../../Models/pet_model.dart';
import '../NewPetScreen/new_pet_screen.dart';
import 'my_pet_card.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalVariables.getPets();
    final mq = MediaQuery.of(context).size;
    List<PetModel> pets = context.watch<GlobalVariables>().allPets;
    List<PetModel> myPets = pets
        .where((pet) => pet.ownerId == GlobalVariables.currentUser.id)
        .toList();
    return Container(
      color: Colors.white,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              pinned: false,
              floating: false,
              leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                  )),
              expandedHeight: mq.height * .3,
              title: const Text(
                'My Pets',
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
              flexibleSpace: Stack(
                children: [
                  Positioned.fill(
                      child: Image.asset(
                    'images/my-pet.png',
                    fit: BoxFit.cover,
                  )),
                ],
              ),
            ),
            myPets.isNotEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                    return MyPetCard(
                      pet: myPets[index],
                      padding: 12,
                    );
                  }, childCount: myPets.length))
                : SliverToBoxAdapter(
                    child: Container(
                      height: mq.height * .5,
                      width: mq.width,
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Text(
                            "You haven't added any pets yet! Add pets to give shelter"),
                      ),
                    ),
                  )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NewPetScreen()));
          },
          label: const Row(
            children: [
              Icon(CupertinoIcons.add),
              SizedBox(
                width: 10,
              ),
              Text('Add new pet'),
            ],
          ),
        ),
      ),
    );
  }
}
