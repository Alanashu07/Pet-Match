import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:pet_match/Services/notification_services.dart';
import 'package:pet_match/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants/global_variables.dart';
import 'Styles/app_style.dart';
import 'firebase_options.dart';
import 'not_connected_screen.dart';

bool? enableLocation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GlobalVariables.loadRestricted();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isConnectedToInternet = true;
  StreamSubscription? _internetStreamSubscription;

  @override
  void initState() {
    getBooleans();
    GlobalVariables.getCurrentUser();
    GlobalVariables.getPets();
    GlobalVariables.getAllUsers();
    GlobalVariables.getCategories();
    GlobalVariables.getAllAccessories();
    super.initState();
    _internetStreamSubscription = InternetConnection().onStatusChange.listen((event) {
      switch(event) {
        case InternetStatus.connected:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
      }
    },);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message!.contains("resumed")) {
        print(true);
        FirebaseServices.updateActiveStatus(true);
      } else {
        print(false);
        FirebaseServices.updateActiveStatus(false);
      }
      return Future.value(message);
    },);
  }

  getBooleans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      enableLocation = prefs.getBool('location');
    });
  }

  @override
  void dispose() {
    _internetStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GlobalVariables(),),
        ChangeNotifierProvider(create: (context) => FirebaseServices(),),
        ChangeNotifierProvider(create: (context) => NotificationServices(),),
      ],
      child: Container(
        color: Colors.white,
        child: MaterialApp(
            title: 'Pet Match',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              indicatorColor: AppStyle.mainColor,
              colorScheme: ColorScheme.fromSeed(seedColor: AppStyle.accentColor),
              scaffoldBackgroundColor: AppStyle.mainColor.withOpacity(0.1),
              appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
              useMaterial3: true,
            ),
            home: isConnectedToInternet ? const SplashScreen() : const NotConnectedScreen()
            // home: const LoginPage()
        ),
      ),
    );
  }
}
