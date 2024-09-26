import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/accessory_model.dart';
import '../image_viewer.dart';

class AccessoryImagesCard extends StatelessWidget {
  final Accessory accessory;
  const AccessoryImagesCard({super.key, required this.accessory});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return SizedBox(
      height: mq.height*.4,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ImageViewer(title: accessory.name, image: accessory.images[index])));
              },
              child: Container(
                width: mq.width*.95, height: mq.height*.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(accessory.images[index]), fit: BoxFit.cover),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            width: 20,
          ),
          itemCount: accessory.images.length),
    );
  }
}
