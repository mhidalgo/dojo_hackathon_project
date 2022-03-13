import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({
    Key? key, required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 64,
        ),
        Text(title,
            style: Theme.of(context).textTheme.caption,),
      ],
    );
  }
}

class PageTitleWithLeadingItem extends PageTitle {
  PageTitleWithLeadingItem({
    required String title,
}) : super(
    title: title,
  );
}

