import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../Constants/global_variables.dart';
import '../../../Models/message_model.dart';
import '../../../Models/user_model.dart';
import '../../../Services/firebase_services.dart';
import '../../../Styles/app_style.dart';
import '../../../date_format.dart';
import 'chatting_screen.dart';

class ChatsTile extends StatefulWidget {
  final double padding;
  final double borderRadius;
  final double height;
  final double width;
  final User sender;

  const ChatsTile(
      {super.key,
      this.padding = 16,
      this.borderRadius = 12,
      required this.sender,
      this.height = 100,
      this.width = double.infinity});

  @override
  State<ChatsTile> createState() => _ChatsTileState();
}

class _ChatsTileState extends State<ChatsTile> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseServices.getLastMessage(widget.sender),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;
        final list =
            data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
        if (data != null && list.isNotEmpty) _message = list[0];

        return Padding(
          padding: EdgeInsets.all(widget.padding),
          child: OpenContainer(
            openColor: Colors.transparent,
            closedColor: Colors.transparent,
            openElevation: 0,
            closedElevation: 0,
            closedBuilder: (context, action) => Container(
              height: widget.height,
              width: widget.width,
              padding: EdgeInsets.all(widget.padding),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  color: AppStyle.mainColor.withOpacity(0.1),
                  border: Border.all(color: AppStyle.mainColor)),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            widget.sender.image ?? GlobalVariables.errorImage),
                      ),
                      widget.sender.isOnline
                          ? const CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.red,
                            )
                          : const SizedBox()
                    ],
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.sender.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _message != null
                              ? _message!.sender ==
                                      GlobalVariables.currentUser.id
                                  ? _message!.type == 'text'
                                      ? 'You: ${_message!.text}'
                                      : 'You: Sent an image 📸'
                                  : _message!.type == 'text'
                                      ? _message!.text
                                      : 'Sent an image 📸'
                              : widget.sender.email,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat.getFormattedTime(
                          context: context,
                          time: _message != null
                              ? _message!.sentAt
                              : widget.sender.lastActive)),
                      _message != null &&
                              _message!.readAt.isEmpty &&
                              _message!.sender != GlobalVariables.currentUser.id
                          ? CircleAvatar(
                              radius: 6,
                              backgroundColor: AppStyle.accentColor,
                            )
                          : const SizedBox()
                    ],
                  )
                ],
              ),
            ),
            openBuilder: (context, action) => ChattingScreen(
                user: GlobalVariables.currentUser, chatUser: widget.sender),
          ),
        );
      },
    );
  }
}
