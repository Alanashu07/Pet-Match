import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:pet_match/Screens/MainScreens/ChatHomeWidgets/chatting_screen.dart';
import '../Styles/app_style.dart';
import '../UrlLauncher/launch_normal_url.dart';
import '../UrlLauncher/launch_uri.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  List contacts = [
    {
      "scheme": 'tel',
      "path": "+918129359344",
      "image": "images/contact/telephone.png",
      "name": "Phone"
    },
    {
      "scheme": 'sms',
      "path": "+918129359344",
      "image": "images/contact/comments.png",
      "name": "Messaging"
    },
    {
      "scheme": 'mailto',
      "path": "alanashu07@gmail.com",
      "image": "images/contact/gmail.png",
      "name": "Email"
    },
  ];

  List social = [
    {
      "name": "Whatsapp",
      "image": "images/contact/whatsapp.png",
      "url": "https://wa.me/+918129359344"
    },
    {
      "name": "Instagram",
      "image": "images/contact/instagram.png",
      "url": "https://www.instagram.com/anas.theri?igsh=ZzVjMDJmaDJnejBq"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(CupertinoIcons.back)),
          title: const Text(
            'Contact Us',
            style: TextStyle(fontSize: 24),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(CupertinoIcons.chat_bubble_text_fill, color: AppStyle.mainColor, size: 50,),
                title: const Text("Chat with us", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                onTap: (){
                  final admins = GlobalVariables.users.where((element) => element.type == 'admin',).toList();
                  Random random = Random();
                  int randomIndex = random.nextInt(admins.length);
                  final admin = admins[randomIndex];
                  Navigator.push(context, PageTransition(child: ChattingScreen(user: GlobalVariables.currentUser, chatUser: admin, isAdmin: true,), type: PageTransitionType.bottomToTop));
                },
              ),
              Text(
                'Contact us on: ',
                style: TextStyle(
                    color: AppStyle.mainColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              ListView.separated(
                itemCount: contacts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => LaunchUri(
                    scheme: contacts[index]["scheme"],
                    path: contacts[index]["path"],
                    image: contacts[index]["image"],
                    name: contacts[index]["name"]),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 25,
                  );
                },
              ),
              const SizedBox(height: 25,),
              ListView.separated(
                itemCount: social.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => LaunchNormalUrl(
                    url: social[index]["url"],
                    image: social[index]["image"],
                    name: social[index]["name"]),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 25,
                  );
                },
              ),
              SizedBox(height: mq.height*.05,),
            ],
          ),
        ),
      ),
    );
  }
}
