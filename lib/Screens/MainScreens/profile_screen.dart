import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ProfileWidgets/profile_options.dart';
import 'ProfileWidgets/user_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100,),
              const UserHeader().animate().slideY().fade(),
              SizedBox(height: mq.height*.04,),
              const ProfileOptions().animate().slideY(begin: 1, end: 0).fade(),
            ],
          )),
    );
  }
}
