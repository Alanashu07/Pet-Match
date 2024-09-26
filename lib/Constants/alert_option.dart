import 'package:flutter/material.dart';

void showAlert({required BuildContext context, required String title, required String content}) {
  showDialog(context: context, builder: (context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
    }, child: Text("OK"))
      ],
    );
  },);
}