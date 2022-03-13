import 'package:flutter/material.dart';

class CloseIconButton extends StatelessWidget {
  const CloseIconButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        print('tap');
      },
    );
  }
}

class QuitGameIcon extends StatelessWidget {
  const QuitGameIcon({Key? key, required this.quitGameIconOnPress})
      : super(key: key);

  final quitGameIconOnPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Ready to quit?'),
          content: const Text('Do you want to give up and quit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('No, never.'),
            ),
            TextButton(
              onPressed: () {
                quitGameIconOnPress();
              },
              child: const Text('Yes, I quit.'),
            ),
          ],
        ),
      ),
    );
  }
}