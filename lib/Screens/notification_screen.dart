import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Screens/accessory_details.dart';
import 'package:pet_match/Screens/categories_screen.dart';
import 'package:pet_match/Screens/pet_details_screen.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:provider/provider.dart';
import '../Constants/global_variables.dart';
import '../Models/notification_model.dart';
import '../date_format.dart';
import 'NotificationWidgets/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<GlobalVariables>().user;
    List<NotificationModel> notifications = [];
    final mq = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseServices.firestore
                .collection(FirebaseServices.usersCollection)
                .doc(user.id!)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Error Fetching data"),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: Text("No notifications yet!"),
                );
              }
              notifications = snapshot.data!['notifications']
                  .map<NotificationModel>((e) =>
                      NotificationModel.fromJson(e as Map<String, dynamic>))
                  .toList();
              return ListView.separated(
                  padding: EdgeInsets.only(bottom: mq.height * .05),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var sender = GlobalVariables.users.firstWhere(
                      (element) => element.id == notifications[index].senderId,
                    );
                    return NotificationTile(
                      notification: notifications[index],
                      sender: sender,
                      onTap: () {
                        context
                            .read<GlobalVariables>()
                            .setRead(notifications[index]);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                    notifications[index].title.isNotEmpty
                                        ? notifications[index].title
                                        : sender.name),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(notifications[index].message),
                                    Row(
                                      children: [
                                        const Spacer(),
                                        Text(DateFormat.getFormattedTime(
                                            context: context,
                                            time: notifications[index].sendAt))
                                      ],
                                    )
                                  ],
                                ),
                                actions: [
                                  notifications[index].page == 'pet' ||
                                          notifications[index].page ==
                                              'categories' ||
                                          notifications[index].page ==
                                              'accessories'
                                      ? TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (notifications[index].page ==
                                                'pet') {
                                              final notificationPet =
                                                  GlobalVariables.pets
                                                      .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    notifications[index].type,
                                              );
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child: PetDetailsScreen(
                                                          pet: notificationPet),
                                                      type: PageTransitionType
                                                          .bottomToTop));
                                            } else if (notifications[index]
                                                    .page ==
                                                'categories') {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child:
                                                          const CategoriesScreen(),
                                                      type: PageTransitionType
                                                          .bottomToTop));
                                            } else if (notifications[index]
                                                    .page ==
                                                'accessories') {
                                              final notificationAccessory =
                                                  GlobalVariables.accessories
                                                      .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    notifications[index].type,
                                              );
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child: AccessoryDetails(
                                                          accessory:
                                                              notificationAccessory),
                                                      type: PageTransitionType
                                                          .bottomToTop));
                                            }
                                          },
                                          child: const Text("Go to Details"))
                                      : const SizedBox(),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Back'))
                                ],
                              );
                            });
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Divider(
                              height: 2,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                  itemCount: notifications.length);
            }),
      ),
    );
  }
}
