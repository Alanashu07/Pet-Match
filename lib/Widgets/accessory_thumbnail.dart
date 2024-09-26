import 'package:flutter/material.dart';
import '../Constants/global_variables.dart';
import '../Models/accessory_model.dart';
import '../Screens/accessory_details.dart';
import '../date_format.dart';

class AccessoryThumbnail extends StatelessWidget {
  final Accessory accessory;

  const AccessoryThumbnail({super.key, required this.accessory});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final category = GlobalVariables.categories.firstWhere(
      (category) => category.id == accessory.category,
    );
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AccessoryDetails(accessory: accessory,)));
      },
      child: Column(
        children: [
          SizedBox(
            width: mq.width,
            height: mq.height * .3,
            child: Image.network(
              accessory.images[0],
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(category.image),
            ),
            title: Text(
              accessory.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                '${accessory.brand} • ₹${accessory.price.round()} • ${DateFormat.getCreatedTime(context: context, time: accessory.createdAt)}'),
            // trailing: PopupMenuButton(
            //   itemBuilder: (context) {
            //     return [
            //       const PopupMenuItem(
            //           child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text('Buy This Item'),
            //           SizedBox(
            //             width: 25,
            //           ),
            //           Text('1')
            //         ],
            //       )),
            //       const PopupMenuItem(
            //           child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(''),
            //           SizedBox(
            //             width: 25,
            //           ),
            //           Text('1')
            //         ],
            //       )),
            //       const PopupMenuItem(
            //           child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text('First Option'),
            //           SizedBox(
            //             width: 25,
            //           ),
            //           Text('1')
            //         ],
            //       )),
            //       const PopupMenuItem(
            //           child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text('First Option'),
            //           SizedBox(
            //             width: 25,
            //           ),
            //           Text('1')
            //         ],
            //       )),
            //     ];
            //   },
            // ),
          ),
        ],
      ),
    );
  }
}
