import 'package:flutter/material.dart';
import '../../Models/notification_model.dart';
import '../../Models/user_model.dart';
import '../../Styles/app_style.dart';
import '../../date_format.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final User sender;
  final VoidCallback onTap;

  const NotificationTile(
      {super.key,
      required this.notification,
      required this.sender,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(notification.image.isNotEmpty ? notification.image : sender.image ??
                  'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png'),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title.isNotEmpty ? notification.title : sender.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
            notification.isRead
                ? Text(DateFormat.getFormattedTime(
                    context: context, time: notification.sendAt))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(DateFormat.getFormattedTime(
                          context: context, time: notification.sendAt)),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppStyle.accentColor,
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
