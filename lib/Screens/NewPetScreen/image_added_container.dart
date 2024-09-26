import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAddedContainer extends StatefulWidget {
  final List<XFile> images;
  const ImageAddedContainer({super.key, required this.images});

  @override
  State<ImageAddedContainer> createState() => _ImageAddedContainerState();
}

class _ImageAddedContainerState extends State<ImageAddedContainer> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return SizedBox(
      height: 200,
      child: ListView.builder(itemBuilder: (context, index) {
        return SizedBox(
          height: 200,
          width: mq.width,
          child: Stack(
            children: [
              Image.file(File(widget.images[index].path), fit: BoxFit.contain,),
              Padding(padding: const EdgeInsets.all(18), child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: IconButton(onPressed: (){
                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: const Text('Sure to delete?'),
                    content: const Text('Are you sure to delete the image?'),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                        setState(() {
                          widget.images.removeAt(index);
                        });
                      }, child: const Text('Delete')),
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: const Text('Cancel')),
                    ],
                  ),);
                }, icon: const Icon(CupertinoIcons.delete)),
              ))
            ],
          ),
          // child: Image.asset('images/dog.png'),
        );
      }, itemCount: widget.images.length, shrinkWrap: true, scrollDirection: Axis.horizontal,),
    );
  }
}
