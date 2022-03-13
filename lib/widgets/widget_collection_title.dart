import 'package:flutter/material.dart';

class WidgetCollectionTitle extends StatelessWidget {
  const WidgetCollectionTitle({
    Key? key, required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 24.0, right: 8.0, bottom:8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.bodyText1),
        ],
      ),
    );
  }
}