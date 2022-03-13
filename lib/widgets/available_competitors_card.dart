import '../style/colors.dart';
import 'package:flutter/material.dart';

// import 'package:dojo_app/colors.dart';
import 'package:dojo_app/widgets/button.dart';

class AvailableCompetitorCard extends StatelessWidget {
  const AvailableCompetitorCard({
    Key? key,
    required this.avatar,
    required this.userName,
    required this.winLossTieRecord,
  }) : super(key: key);

  final String avatar;
  final String userName;
  final String winLossTieRecord;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4, right: 4),
      child: Card(
        color: primarySolidCardColor,
        child: InkWell(
          splashColor: Colors.red.withAlpha(30),
          onTap: () {
            print('tap');
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(avatar),
                      ),
                      title: Text(userName),
                      subtitle: Text(winLossTieRecord),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  LowEmphasisButton(title: 'CHALLENGE'),
                  //const SizedBox(width: 8),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
