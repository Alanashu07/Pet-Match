import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../Styles/app_style.dart';

class RatingIcon extends StatelessWidget {
  final double rating;
  const RatingIcon({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(itemBuilder: (context, index) {
      return Icon(Icons.star, color: AppStyle.accentColor,);
    }, direction: Axis.horizontal, rating: rating,);
  }
}
