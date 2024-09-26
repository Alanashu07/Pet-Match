import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../../Constants/global_variables.dart';
import '../../../Models/rating_model.dart';
import '../../../Services/firebase_services.dart';
import '../../../Styles/app_style.dart';
import '../../../Widgets/custom_text_field.dart';
import '../../MyPets/my_pets_screen.dart';
import '../../Settings/settings_screen.dart';
import '../../contact_us.dart';
import '../../login_page.dart';
import '../AdoptedPets/adopted_pets_screen.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(height: 30, width: 30, child: Image.asset('images/pet-care.png', color: Colors.black.withOpacity(0.7),),),
            title: const Text(
              'My Pets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: const MyPetsScreen(),
                      type: PageTransitionType.rightToLeft));
            },
          ),
          ListTile(
            leading: SizedBox(height: 30, width: 30, child: Image.asset('images/adopted-cat.png', color: Colors.black.withOpacity(0.7),),),
            title: const Text(
              'Adopted Pets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: const AdoptedPetsScreen(),
                      type: PageTransitionType.rightToLeft));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              size: 30,
            ),
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: const SettingsScreen(),
                      type: PageTransitionType.rightToLeft));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.share,
              size: 30,
            ),
            title: const Text(
              'Share to a friend',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              String imageUrl = "https://res.cloudinary.com/diund1rdq/image/upload/v1726933171/h5zhtm65pzrkxvx2yucc.png";
              final url = Uri.parse(imageUrl);
              final response = await http.get(url);
              final bytes = response.bodyBytes;

              final temp = await getTemporaryDirectory();
              final path = '${temp.path}/image.png';
              File(path).writeAsBytesSync(bytes);
              await Share.shareXFiles([XFile(path)], text: 'Check out this image I found on Pet Match App');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.headset_mic,
              size: 30,
            ),
            title: const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: const ContactUs(),
                      type: PageTransitionType.rightToLeft));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.stars,
              size: 30,
            ),
            title: const Text(
              'Rate Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              double rating = 0;
              TextEditingController ratingController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Rate Us"), Icon(CupertinoIcons.info)],
                    ),
                    content: StatefulBuilder(builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          RatingBar(
                            initialRating: rating,
                            allowHalfRating: true,
                            direction: Axis.horizontal,
                            ratingWidget: RatingWidget(
                                full: Icon(
                                  Icons.star,
                                  color: AppStyle.accentColor,
                                ),
                                half: Icon(
                                  CupertinoIcons.star_lefthalf_fill,
                                  color: AppStyle.accentColor,
                                ),
                                empty: Icon(
                                  Icons.star_outline,
                                  color: AppStyle.accentColor,
                                )),
                            onRatingUpdate: (value) {
                              state(() {
                                rating = value;
                              });
                            },
                          ),
                          CustomTextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: ratingController,
                              hintText: 'Describe your experience...',
                              type: 'rating'),
                        ],
                      );
                    }),
                    actions: [
                      TextButton(
                          onPressed: () {
                            int now = DateTime.now().millisecondsSinceEpoch;
                            if (rating == 0) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Please Rate"),
                                  content: const Text(
                                      "Looks like you didn't give any rating😐. Please give your experience"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("OK"))
                                  ],
                                ),
                              );
                            } else {
                              FirebaseServices.addRating(
                                  rating: rating,
                                  description: ratingController.text.trim());
                              GlobalVariables.ratings.add(RatingModel(
                                  rating: rating,
                                  description: ratingController.text.trim(),
                                  time: now.toString(),
                                  id: '${GlobalVariables.currentUser.id}-$now',
                                  userId: GlobalVariables.currentUser.id!));
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Thank You!"),
                                  content: const Text(
                                      "Thank You for sharing your experience.😍"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("OK"))
                                  ],
                                ),
                              );
                            }
                          },
                          child: const Text("Submit")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel")),
                    ],
                  ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: const Duration(milliseconds: 200)).fade();
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              size: 30,
            ),
            title: const Text(
              'Log out',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await FirebaseServices.updateActiveStatus(false);
              await FirebaseServices.auth.signOut();
              await GoogleSignIn().signOut();
              context.read<GlobalVariables>().emptyRestriction();
              GlobalVariables.getCategories();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          SizedBox(
            height: mq.height * .1,
          )
        ],
      ),
    );
  }
}
