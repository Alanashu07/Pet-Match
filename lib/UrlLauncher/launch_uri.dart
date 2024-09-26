import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUri extends StatefulWidget {
  final String scheme;
  final String path;
  final String image;
  final String name;

  const LaunchUri(
      {super.key,
      required this.scheme,
      required this.path,
      required this.image,
      required this.name});

  @override
  State<LaunchUri> createState() => _LaunchUriState();
}

class _LaunchUriState extends State<LaunchUri> {
  _launchUrl({required String scheme, required String path}) async {
    final Uri uri = Uri(scheme: scheme, path: path);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
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
      onTap: () => _launchUrl(scheme: widget.scheme, path: widget.path),
    );
  }
}
