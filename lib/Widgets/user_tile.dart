import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Constants/global_variables.dart';
import '../Models/user_model.dart';
import '../date_format.dart';

class UserTile extends StatelessWidget {
  final Color color;
  final User user;
  final bool showJoinedOn;
  const UserTile({super.key, required this.color, required this.user, this.showJoinedOn = true});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 200.ms,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withOpacity(.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.image ?? GlobalVariables.errorImage),
          ),
          const SizedBox(width: 15,),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
              Text(user.phoneNumber, style: const TextStyle(fontSize: 16, color: Colors.black54),)
            ],
          )),
          showJoinedOn ? Text(DateFormat.getCreatedTime(context: context, time: user.joinedOn)) : const SizedBox()
        ],
      ),
    );
  }
}
