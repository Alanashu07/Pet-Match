import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String title;
  final String image;
  const ImageViewer({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(CupertinoIcons.back, color: Colors.white)),
        title: Text(title, style: const TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Center(child: InteractiveViewer(clipBehavior: Clip.none,child: Image.network(image),)),
    );
  }
}
