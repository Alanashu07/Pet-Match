import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:pet_match/Screens/AdoptionProcedure/procedure_screen.dart';
import 'package:pet_match/Styles/app_style.dart';
import 'package:pet_match/Widgets/search_field.dart';
import 'package:pet_match/Widgets/user_tile.dart';
import 'package:provider/provider.dart';
import '../../Models/user_model.dart';

class AdoptionScreen extends StatefulWidget {
  final PetModel pet;

  const AdoptionScreen({super.key, required this.pet});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  int selectedIndex = -1;

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    await GlobalVariables.getAllUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: widget.pet.ownerId == GlobalVariables.currentUser.id
          ? givePet(context: context)
          : getPet(),
    );
  }

  Widget givePet({required BuildContext context}) {
    final mq = MediaQuery.of(context).size;
    TextEditingController controller = TextEditingController();
    final users = context
        .watch<GlobalVariables>()
        .allUsers
        .where(
          (element) => element.id != GlobalVariables.currentUser.id,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Give ${widget.pet.name} for adoption"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SearchField(
                controller: controller,
                isSearchScreen: true,
                onSubmitted: (value) {
                  List<User> searchedUsers = users
                      .where(
                        (element) =>
                            element.name
                                .toLowerCase()
                                .contains(controller.text.trim()) ||
                            element.email
                                .toLowerCase()
                                .contains(controller.text.trim()) ||
                            element.phoneNumber
                                .toLowerCase()
                                .contains(controller.text.trim()) ||
                            element.location!
                                .toLowerCase()
                                .contains(controller.text.trim()),
                      )
                      .toList();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Select a user"),
                        content: searchedUsers.isEmpty
                            ? const Text("No users with given details!")
                            : Container(
                                height: mq.height,
                                width: mq.width,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = users.indexWhere(
                                                (element) =>
                                                    element.id ==
                                                    searchedUsers[index].id,
                                              );
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: UserTile(
                                            color: AppStyle.mainColor,
                                            user: searchedUsers[index],
                                            showJoinedOn: false,
                                          )),
                                    );
                                  },
                                  itemCount: searchedUsers.length,
                                ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            selectedIndex >= 0
                ? Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selected User: ",
                          style: TextStyle(
                              color: AppStyle.accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: UserTile(
                              color: AppStyle.accentColor,
                              user: users[selectedIndex]),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "Select a user to give ${widget.pet.name}",
                style: TextStyle(fontSize: 20, color: AppStyle.mainColor),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: UserTile(
                              color: selectedIndex == index
                                  ? AppStyle.accentColor
                                  : AppStyle.mainColor,
                              user: users[index])));
                },
                itemCount: users.length)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedIndex < 0) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("User not selected"),
                  content: Text(
                      "Please select a user to give ${widget.pet.name} for adoption"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OK"))
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      "Give ${widget.pet.name} to ${users[selectedIndex].name}?"),
                  content: Text(
                      "Confirm that you wish to give ${widget.pet.name} to ${users[selectedIndex].name}"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ProcedureScreen(
                                      pet: widget.pet,
                                      user: users[selectedIndex]),
                                  type: PageTransitionType.bottomToTop));
                        },
                        child: const Text("Yes")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No")),
                  ],
                );
              },
            );
          }
        },
        child: const Icon(CupertinoIcons.arrow_right),
      ),
    );
  }

  Widget getPet() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adopt ${widget.pet.name}"),
      ),
    );
  }
}
