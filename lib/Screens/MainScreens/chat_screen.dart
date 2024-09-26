import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:provider/provider.dart';

import '../../Constants/global_variables.dart';
import '../../Models/user_model.dart';
import '../../Styles/app_style.dart';
import 'ChatHomeWidgets/chats_tile.dart';
import 'bottom_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int sortIndex = 0;

  List<User> users = [];

  List<String>? initialUsers;

  sortChats() {
    if (sortIndex == 0) {
      users.sort((b, a) => a.lastActive.compareTo(b.lastActive));
    } else if (sortIndex == 1) {
      users.sort((a, b) => a.lastActive.compareTo(b.lastActive));
    } else if (sortIndex == 2) {
      users.sort((b, a) => a.name.compareTo(b.name));
    } else if (sortIndex == 3) {
      users.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  @override
  void initState() {
    getInitialUsers();
    super.initState();
  }

  getInitialUsers() async {
    final data = await FirebaseServices.firestore.collection(FirebaseServices.usersCollection).doc(GlobalVariables.currentUser.id).collection('my_users').get();
    initialUsers = data.docs.map((e) => e.id).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      body: initialUsers == null ? const Center(
        child: CircularProgressIndicator(),
      ) : initialUsers!.isEmpty ? Center(
        child: Container(
          height: mq.height * .5,
          width: mq.width,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chat_bubble_text,
                color: AppStyle.accentColor,
                size: mq.width * .1,
              ),
              Text(
                "No Chatting yet!",
                style: TextStyle(
                    color: AppStyle.accentColor,
                    fontSize: 20),
              ),
            ],
          ),
        ),
      ) : StreamBuilder(
        stream: FirebaseServices.getMyUserId(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(
              child: Container(
                height: mq.height * .5,
                width: mq.width,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble_text,
                      color: AppStyle.accentColor,
                      size: mq.width * .1,
                    ),
                    Text(
                      "No Chatting yet!",
                      style: TextStyle(
                          color: AppStyle.accentColor,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
            return StreamBuilder(
                stream: FirebaseServices.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );

                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      users =
                          data?.map((e) => User.fromJson(e.data())).toList() ?? [];
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50))),
                        pinned: false,
                        floating: false,
                        leadingWidth: 100,
                        leading: InkWell(
                          onTap: () {
                            navigationKey.currentState!.setPage(3);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(context
                                      .watch<GlobalVariables>()
                                      .user
                                      .image ??
                                  GlobalVariables.errorImage),
                            ),
                          ),
                        ),
                        expandedHeight: mq.height * .3,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello!',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              context.watch<GlobalVariables>().user.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        flexibleSpace: Stack(
                          children: [
                            Positioned.fill(
                                child: Image.asset(
                              'images/animals.png',
                              fit: BoxFit.cover,
                            )),
                            Container(
                              width: mq.width,
                              height: mq.height * .3,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black54
                                  ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                            ),
                            const Positioned(
                              bottom: 0,
                              child: Padding(
                                padding: EdgeInsets.all(18.0),
                                child: Text(
                                  'Pets take your stress away',
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        ).animate().slideY(),
                      ),
                      SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Chats",
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        PopupMenuButton(
                                          onSelected: (value) {
                                            setState(() {
                                              sortIndex = value;
                                            });
                                          },
                                          child: Icon(
                                            CupertinoIcons.sort_down,
                                            color: AppStyle.mainColor,
                                            size: 35,
                                          ),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Last Active"),
                                                  Icon(
                                                    CupertinoIcons.arrow_down,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Last Active"),
                                                  SizedBox(
                                                    width: 30,
                                                  ),
                                                  Icon(
                                                    CupertinoIcons.arrow_up,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Name"),
                                                  Icon(
                                                    CupertinoIcons.arrow_down,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 3,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Name"),
                                                  Icon(
                                                    CupertinoIcons.arrow_up,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ).animate().fade(),
                              childCount: 1)),
                      users.isNotEmpty
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                sortChats();
                                return ChatsTile(sender: users[index])
                                    .animate()
                                    .slideY(begin: 1, end: 0)
                                    .fade();
                              }, childCount: users.length),
                            )
                          : SliverToBoxAdapter(
                              child: Container(
                                height: mq.height * .5,
                                width: mq.width,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.chat_bubble_text,
                                      color: AppStyle.accentColor,
                                      size: mq.width * .1,
                                    ),
                                    Text(
                                      "No Chatting yet!",
                                      style: TextStyle(
                                          color: AppStyle.accentColor,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) => SizedBox(
                                    height: mq.height * .3,
                                  ),
                              childCount: 1))
                    ],
                  );
                });
          }
        },
      ),
    );
  }
}
