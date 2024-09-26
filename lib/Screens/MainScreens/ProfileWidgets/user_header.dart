import 'dart:io';
import 'package:animations/animations.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:pet_match/image_viewer.dart';
import 'package:provider/provider.dart';
import '../../../Constants/global_variables.dart';
import '../../../Styles/app_style.dart';
import '../../../Widgets/custom_text_field.dart';

class UserHeader extends StatelessWidget {
    const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<GlobalVariables>().user;
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    return Column(
      children: [
        OpenContainer(
          closedElevation: 0,
          closedColor: Colors.transparent,
          openElevation: 0,
          openColor: Colors.transparent,
          closedBuilder: (context, action) => CircleAvatar(
          backgroundImage: NetworkImage(user.image ??
              'https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg'),
          radius: 60,
        ), openBuilder: (context, action) => ImageViewer(title: user.name, image: user.image!),),
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.grey, fontSize: 18),
        ),
        Text(
          user.phoneNumber,
          style: const TextStyle(color: Colors.grey, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                String imageUrl = user.image ?? '';
                nameController.text = user.name;
                phoneNumberController.text = user.phoneNumber;
                return AlertDialog(
                  title: const Text('Edit your profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final timeStamp =
                                DateTime.now().millisecondsSinceEpoch;
                            FirebaseStorage storage = FirebaseStorage.instance;
                            Reference ref = storage.ref().child('users/${user.id}/$timeStamp');
                            await ref.putFile(File(pickedFile.path));
                            imageUrl = await ref.getDownloadURL();
                            context.read<GlobalVariables>().updateUser(
                                name: nameController.text.trim(),
                                phoneNumber: phoneNumberController.text.trim(),
                                newImage: imageUrl);
                            await FirebaseServices.updateUser(
                                user: user,
                                name: nameController.text.trim(),
                                phoneNumber: phoneNumberController.text.trim(),
                                newImage: imageUrl);
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              user.image ?? GlobalVariables.errorImage),
                          radius: 40,
                        ),
                      ),
                      Row(
                        children: [
                          const Expanded(flex: 1, child: Text("Name")),
                          const Text(":"),
                          Expanded(
                              flex: 3,
                              child: CustomTextField(
                                controller: nameController,
                                hintText: 'Enter your name',
                                type: 'name',
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(flex: 1, child: Text("Phone Number")),
                          const Text(":"),
                          Expanded(
                              flex: 3,
                              child: CustomTextField(
                                textInputType:
                                    const TextInputType.numberWithOptions(
                                        signed: true, decimal: false),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9+]'))
                                ],
                                controller: phoneNumberController,
                                hintText: 'Enter your Phone Number',
                                type: 'number',
                              )),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          context.read<GlobalVariables>().updateUser(
                              name: nameController.text.trim(),
                              phoneNumber: phoneNumberController.text.trim(),
                              newImage: imageUrl);
                          FirebaseServices.updateUser(
                              user: user,
                              name: nameController.text.trim(),
                              phoneNumber: phoneNumberController.text.trim(),
                              newImage: imageUrl);
                          Navigator.pop(context);
                        },
                        child: const Text('Submit')),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                  ],
                );
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit',
                style: TextStyle(
                    color: AppStyle.mainColor,
                    decoration: TextDecoration.underline,
                    fontSize: 20,
                    decorationColor: AppStyle.mainColor),
              ),
              const SizedBox(
                width: 10,
              ),
              Icon(
                Icons.edit,
                color: AppStyle.mainColor,
                size: 20,
              )
            ],
          ),
        ),
      ],
    );
  }
}
