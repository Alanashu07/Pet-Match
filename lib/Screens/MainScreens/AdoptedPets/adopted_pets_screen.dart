import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/Screens/MainScreens/bottom_bar.dart';
import 'package:pet_match/Widgets/login_button.dart';
import 'package:provider/provider.dart';
import '../../../Constants/global_variables.dart';
import '../../../Models/pet_model.dart';
import 'adopted_pet_card.dart';

class AdoptedPetsScreen extends StatefulWidget {
  const AdoptedPetsScreen({super.key});

  @override
  State<AdoptedPetsScreen> createState() => _AdoptedPetsScreenState();
}

class _AdoptedPetsScreenState extends State<AdoptedPetsScreen> {
  List<PetModel> adoptedPets = [];

  getAdoptedPets() {
    for (var pet in GlobalVariables.pets) {
      for (var id in GlobalVariables.currentUser.adoptedPets) {
        if (id == pet.id && !adoptedPets.contains(pet)) {
          adoptedPets.add(pet);
          break;
        }
      }
    }
  }

  @override
  void initState() {
    getAdoptedPets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalVariables.getPets();
    final takenPets = context
        .watch<GlobalVariables>()
        .allPets
        .where(
          (element) => adoptedPets.contains(element),
        )
        .toList();
    final mq = MediaQuery.of(context).size;
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
                'My Adopted Pets',
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
            takenPets.isNotEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                    return AdoptedPetCard(pet: takenPets[index]);
                  }, childCount: takenPets.length))
                : SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: mq.height * .5,
                          width: mq.width,
                          alignment: Alignment.center,
                          child: const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Text(
                                "You haven't adopted any pets yet! Give shelters to some pets"),
                          ),
                        ),
                        LoginButton(
                          onTap: () {
                            navigationKey.currentState!.setPage(0);
                            Navigator.pop(context);
                          },
                          width: mq.width * .5,
                          child: const Text(
                            "Explore now",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
