import 'package:flutter/material.dart';

class NoImageContainer extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onTap;
  const NoImageContainer({super.key, this.height = 200, this.width = double.infinity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color:Colors.black26),
            borderRadius: BorderRadius.circular(12)
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 50,color: Colors.black26,),
              SizedBox(height: 15,),
              Text('No Image Selected', style: TextStyle(color: Colors.black26),)
            ],
          ),
        ),
      ),
    );
  }
}
