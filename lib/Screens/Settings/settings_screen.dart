import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_match/Screens/Restricted/restricted_categories_screen.dart';
import 'package:pet_match/Screens/Restricted/restricted_pets_screen.dart';
import 'package:pet_match/Screens/login_page.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/global_variables.dart';
import '../../Models/rating_model.dart';
import '../../Services/location_services.dart';
import '../../Styles/app_style.dart';
import '../../Widgets/custom_text_field.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final passwordKey = GlobalKey<FormState>();
  bool isGettingLocation = false;

  @override
  void initState() {
    getBooleans();
    super.initState();
  }

  getBooleans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      enableLocation = prefs.getBool('location');
    });
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Open app's notification settings in system settings
  Future<void> _openNotificationSettings() async {
    await openAppSettings();
  }

  showAlert(
      {required String title,
      required String content,
      required String buttonText}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(buttonText))
          ],
        );
      },
    );
  }

  changePassword(String newPassword) async {
    var credential = EmailAuthProvider.credential(
        email: GlobalVariables.currentUser.email,
        password: GlobalVariables.currentUser.password!);

    await FirebaseServices.auth.currentUser!
        .reauthenticateWithCredential(credential)
        .then(
      (value) {
        FirebaseServices.auth.currentUser!.updatePassword(newPassword);
        FirebaseServices.firestore
            .collection(FirebaseServices.usersCollection)
            .doc(FirebaseServices.auth.currentUser!.uid)
            .update({'password': newPassword});
      },
    ).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppStyle.mainColor,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isGettingLocation
                    ? const LinearProgressIndicator().animate().slideX()
                    : const SizedBox(),
                ListTile(
                  onTap: _openNotificationSettings,
                  title: const Text('Enable notification'),
                  subtitle: const Text(
                      'Prefer to enable/disable push notifications. Unselecting this will stop sending recommendations, and other messages'),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Location'),
                  subtitle: const Text(
                      'Set your location, if you don\'t want to set location, disable.'),
                  onTap: () async {
                    if (enableLocation != false) {
                      setState(() {
                        isGettingLocation = true;
                      });
                      LocationServices locationServices = LocationServices();
                      try {
                        Position position =
                            await locationServices.getCurrentPosition();
                        List<Placemark> placemarks =
                            await placemarkFromCoordinates(
                                position.latitude, position.longitude);
                        Placemark place = placemarks[0];
                        final data = ({
                          'latitude': position.latitude,
                          'longitude': position.longitude,
                          'location':
                              '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}',
                        });
                        FirebaseServices.firestore
                            .collection(FirebaseServices.usersCollection)
                            .doc(GlobalVariables.currentUser.id!)
                            .update(data);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Location updated Successfully"),
                          backgroundColor: AppStyle.mainColor,
                        ));
                        setState(() {
                          isGettingLocation = false;
                        });
                      } catch (e) {
                        setState(() {
                          isGettingLocation = false;
                        });
                        return Future.error(e);
                      }
                    }
                  },
                  trailing: Switch(
                    value: enableLocation ?? true,
                    onChanged: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('location', value);
                      setState(() {
                        enableLocation = prefs.getBool('location');
                      });
                    },
                  ),
                ),
                const Text(
                  'Account Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                ListTile(
                  title: const Text('Link social Media'),
                  subtitle: const Text(
                      'Link your social media accounts with Pet Match app'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Change Password'),
                  subtitle: const Text(
                      'Change your current password and set a new Password'),
                  onTap: () {
                    bool isSecureOldPassword = true;
                    bool isSecureNewPassword = true;
                    bool isSecureConfirmPassword = true;
                    TextEditingController oldPassword = TextEditingController();
                    TextEditingController newPassword = TextEditingController();
                    TextEditingController confirmNewPassword =
                        TextEditingController();
                    if (GlobalVariables.currentUser.password == null ||
                        GlobalVariables.currentUser.password!.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Wrong authentication"),
                            content: const Text(
                                "You used google for authentication, you cannot change the password. You can only login using Google authentication"),
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
                          return StatefulBuilder(builder: (context, state) {
                            return AlertDialog(
                              title: const Text("Change Password"),
                              content: Form(
                                key: passwordKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextField(
                                        hideText: isSecureOldPassword,
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              state(() {
                                                isSecureOldPassword =
                                                    !isSecureOldPassword;
                                              });
                                            },
                                            icon: Icon(isSecureOldPassword
                                                ? CupertinoIcons.eye
                                                : CupertinoIcons.eye_slash)),
                                        controller: oldPassword,
                                        hintText: "Enter Current Password",
                                        type: 'Current Password'),
                                    CustomTextField(
                                        hideText: isSecureNewPassword,
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              state(() {
                                                isSecureNewPassword =
                                                    !isSecureNewPassword;
                                              });
                                            },
                                            icon: Icon(isSecureNewPassword
                                                ? CupertinoIcons.eye
                                                : CupertinoIcons.eye_slash)),
                                        controller: newPassword,
                                        hintText: 'Enter new password',
                                        type: 'New Password'),
                                    CustomTextField(
                                        hideText: isSecureConfirmPassword,
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              state(() {
                                                isSecureConfirmPassword =
                                                    !isSecureConfirmPassword;
                                              });
                                            },
                                            icon: Icon(isSecureConfirmPassword
                                                ? CupertinoIcons.eye
                                                : CupertinoIcons.eye_slash)),
                                        controller: confirmNewPassword,
                                        hintText: 'Confirm new password',
                                        type: 'Confirm New Password'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (oldPassword.text.isEmpty) {
                                        showAlert(
                                          title: 'Password is Empty',
                                          content:
                                              'Current Password cannot be empty',
                                          buttonText: 'Ok',
                                        );
                                      } else if (newPassword.text.isEmpty) {
                                        showAlert(
                                          title: 'New Password is Empty',
                                          content:
                                              'New Password cannot be empty',
                                          buttonText: 'Ok',
                                        );
                                      } else if (newPassword.text !=
                                          confirmNewPassword.text) {
                                        showAlert(
                                          title: 'Passwords doesn\'t match',
                                          content:
                                              'New Password and Confirm New password does not match it must be equal to continue',
                                          buttonText: 'Ok',
                                        );
                                      } else if (oldPassword.text !=
                                          GlobalVariables
                                              .currentUser.password) {
                                        showAlert(
                                            title: "Wrong Password",
                                            content:
                                                "The password you entered does not match with the users password. Please input valid credentials",
                                            buttonText: 'Cancel');
                                      } else if (passwordKey.currentState!
                                          .validate()) {
                                        changePassword(newPassword.text);
                                        Navigator.pop(context);
                                      } else {
                                        showAlert(
                                          title: 'Unknown Error',
                                          content:
                                              'Something unexpected happened during the action. Please try again later',
                                          buttonText: 'Ok',
                                        );
                                      }
                                    },
                                    child: const Text("Update")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel")),
                              ],
                            );
                          });
                        },
                      );
                    }
                  },
                ),
                ListTile(
                  title: const Text('Two Step Authentication'),
                  subtitle: const Text(
                      'Enable/Disable two step authentication to your account'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Delete Account'),
                  subtitle: const Text(
                      'Delete your account, you will no longer be here'),
                  onTap: () {
                    if (GlobalVariables.currentUser.pets!.isNotEmpty) {
                      showAlert(
                          title: "Action not allowed!",
                          content:
                              'You cannot delete your account while you have pets in the app, if you want to delete your account, you have to delete your pets first.',
                          buttonText: "OK");
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Account?"),
                            content: const Text(
                                "Are you sure you want to delete your account? This will delete all your data including your interactions and your authentication details. You can still use this app as a new user from the starting steps."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    FirebaseServices.firestore
                                        .collection(
                                            FirebaseServices.usersCollection)
                                        .doc(GlobalVariables.currentUser.id)
                                        .delete();
                                    FirebaseServices.auth.currentUser!.delete();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      PageTransition(
                                          child: const LoginPage(),
                                          type: PageTransitionType.rightToLeft),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text("Delete")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel")),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
                const Text(
                  'App Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                ListTile(
                  title: const Text('Disable categories'),
                  subtitle: const Text(
                      'Disable categories that you do not want to see in the app'),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: const RestrictedCategoriesScreen(),
                            type: PageTransitionType.rightToLeft));
                  },
                ),
                ListTile(
                  title: const Text('Restricted Pets'),
                  subtitle: const Text(
                      'View pets that you have restricted from viewing in the app.'),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: const RestrictedPetsScreen(),
                            type: PageTransitionType.rightToLeft));
                  },
                ),
                ListTile(
                  title: const Text('Download data'),
                  subtitle: const Text('Download your interaction in the app'),
                  onTap: () {},
                ),
                const Text(
                  'Other Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                ListTile(
                  title: const Text('Terms and Conditions'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('FAQs'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Rate the app'),
                  onTap: () {
                    double rating = 0;
                    TextEditingController ratingController =
                        TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rate Us"),
                              Icon(CupertinoIcons.info)
                            ],
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
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: ratingController,
                                    hintText: 'Describe your experience...',
                                    type: 'rating'),
                              ],
                            );
                          }),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  int now =
                                      DateTime.now().millisecondsSinceEpoch;
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
                                        description:
                                            ratingController.text.trim());
                                    GlobalVariables.ratings.add(RatingModel(
                                        rating: rating,
                                        description: ratingController.text
                                            .trim(),
                                        time: now.toString(),
                                        id:
                                            '${GlobalVariables.currentUser.id}-$now',
                                        userId:
                                            GlobalVariables.currentUser.id!));
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
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: mq.height * .05,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
