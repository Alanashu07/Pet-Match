import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchNormalUrl extends StatefulWidget {
  final String image;
  final String name;
  final String url;
  const LaunchNormalUrl({super.key, required this.image, required this.name, required this.url});

  @override
  State<LaunchNormalUrl> createState() => _LaunchNormalUrlState();
}

class _LaunchNormalUrlState extends State<LaunchNormalUrl> {

  _launchUrl(String url) async {
    if(await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    }
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(widget.image),
      title: Text(
        widget.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      onTap: () => _launchUrl(widget.url),
    );;
  }
}
