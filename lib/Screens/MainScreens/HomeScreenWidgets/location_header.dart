import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../Constants/global_variables.dart';
import '../../../Styles/app_style.dart';
import '../../notification_screen.dart';

class LocationHeader extends StatelessWidget {
  final VoidCallback getLocation;
  final String location;
  final bool isGettingLocation;

  const LocationHeader(
      {super.key,
      required this.getLocation,
      required this.location,
      required this.isGettingLocation});

  @override
  Widget build(BuildContext context) {
    final notifications = context
        .watch<GlobalVariables>()
        .user
        .notifications
        .where(
          (element) => !element.isRead,
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          isGettingLocation? const LinearProgressIndicator().animate().slideX() : const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Location",
                          style: TextStyle(fontSize: 18),
                        ),
                        IconButton(
                            onPressed: getLocation,
                            icon: Icon(
                              CupertinoIcons.chevron_down,
                              size: 18,
                              color: AppStyle.mainColor,
                            ))
                      ],
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              OpenContainer(
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                closedElevation: 0,
                openElevation: 0,
                closedBuilder: (context, action) => Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(50)),
                child:  Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const Icon(Icons.notifications_none),
                    notifications.isEmpty
                        ? Container()
                        : CircleAvatar(
                      radius: 4,
                      backgroundColor: AppStyle.accentColor,
                    )
                  ],
                ),
              ).animate().shake(delay: 500.ms), openBuilder: (context, action) => const NotificationScreen(),)
            ],
          ),
        ],
      ),
    );
  }
}

class TypewriterTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const TypewriterTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // Create a Tween to calculate the size of the clipping rect
    animation.drive(
      RectTween(
        begin: const Rect.fromLTRB(0, 0, 0, 1),  // Initially no text is visible
        end: const Rect.fromLTRB(0, 0, 1, 1),    // All text is revealed gradually
      ),
    );

    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft, // Start from left like typewriter
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            // Use an Opacity and ClipRect to reveal text progressively
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: animation.value,  // Reveals text character by character
                child: child,
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }
}