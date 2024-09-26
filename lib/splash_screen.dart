import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Models/user_model.dart';
import 'package:pet_match/Styles/app_style.dart';
import 'Screens/MainScreens/bottom_bar.dart';
import 'Screens/login_page.dart';
import 'Screens/pending_screen.dart';
import 'Services/firebase_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    await GlobalVariables.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery
        .of(context)
        .size;
    return FutureBuilder(
      future: getCurrentUser(), builder: (context, snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
        case ConnectionState.none:
          return Scaffold(
            body: Center(
              child: LottieBuilder.asset('assets/Pet Match Animation.json'),
            ),
          );
        case ConnectionState.active:
        case ConnectionState.done:
      }
      Widget nextScreen = FirebaseServices.auth.currentUser == null
          ? const LoginPage()
          : GlobalVariables.currentUser.type != 'user'
          ? const PendingScreen()
          : const BottomBar();
      return AnimatedSplashScreen(
        splash: Center(
          child: LottieBuilder.asset('assets/Pet Match Animation.json'),
        ),
        splashIconSize: mq.width,
        nextScreen: nextScreen,
        pageTransitionType: PageTransitionType.rightToLeft,
        backgroundColor: AppStyle.mainColor.withOpacity(0.1),
      );
    },);
  }
}
