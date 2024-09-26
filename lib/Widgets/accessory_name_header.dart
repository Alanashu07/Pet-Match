import 'package:flutter/material.dart';
import '../Models/accessory_model.dart';
import '../Styles/app_style.dart';

class AccessoryNameHeader extends StatelessWidget {
  final Accessory accessory;
  const AccessoryNameHeader({super.key, required this.accessory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(accessory.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                Text(accessory.brand, style: const TextStyle(color: Colors.grey, fontSize: 18), overflow: TextOverflow.ellipsis)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('₹ ${accessory.price.round()}', style: TextStyle(color: AppStyle.mainColor, fontSize: 20, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }
}
