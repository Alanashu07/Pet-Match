import 'package:flutter/material.dart';

class NotConnectedScreen extends StatelessWidget {
  const NotConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 50, color: Colors.red,),
            SizedBox(height: 10,),
            Text("No Internet Connection", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Text("Please connect to the internet to explore the application")
          ],
        ),
      ),
    );
  }
}
