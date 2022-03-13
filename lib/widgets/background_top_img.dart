import 'package:flutter/material.dart';

class BackgroundTopImage extends StatelessWidget {
  const BackgroundTopImage({
    Key? key, required this.imageURL,
  }) : super(key: key);

  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageURL),
          //fit: BoxFit.fitHeight
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}