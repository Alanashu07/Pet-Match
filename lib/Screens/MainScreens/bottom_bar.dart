import 'package:animations/animations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_match/Models/user_model.dart';
import 'package:pet_match/Screens/MainScreens/profile_screen.dart';
import '../../Constants/global_variables.dart';
import '../../Services/firebase_services.dart';
import '../../Styles/app_style.dart';
import 'chat_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

final navigationKey = GlobalKey<CurvedNavigationBarState>();

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int index = 0;
  bool isLower = false;
  User? user;

  final items = [
    const Icon(
      Icons.home,
      size: 30,
    ),
    const Icon(
      CupertinoIcons.chat_bubble_2_fill,
      size: 30,
    ),
    const Icon(
      Icons.favorite,
      size: 30,
    ),
    const Icon(
      Icons.person,
      size: 30,
    ),
  ];

  final screens = [
    const HomeScreen(),
    const ChatScreen(),
    const FavouritesScreen(),
    const ProfileScreen()
  ];

  @override
  void initState() {
    getUser();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message!.contains("resumed")) {
        FirebaseServices.updateActiveStatus(true);
      } else {
        FirebaseServices.updateActiveStatus(false);
      }
      return Future.value(message);
    },);
    super.initState();
  }

  getUser() async {
    user = await GlobalVariables.getCurrentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageTransitionSwitcher(
              reverse: isLower,
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              ),
              child: screens[index],
            ),
      bottomNavigationBar: Theme(
        data: ThemeData(iconTheme: const IconThemeData(color: Colors.white)),
        child: CurvedNavigationBar(
          key: navigationKey,
          items: items,
          index: index,
          backgroundColor: Colors.transparent,
          height: 60,
          color: AppStyle.accentColor,
          buttonBackgroundColor: AppStyle.accentColor,
          onTap: (index) {
            setState(() {
              if (index < this.index) {
                isLower = true;
              } else {
                isLower = false;
              }
              this.index = index;
            });
          },
        ),
      ),
    );
  }
}
