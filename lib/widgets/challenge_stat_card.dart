import 'package:flutter/material.dart';

class ChallengeStatCard extends StatelessWidget {
  const ChallengeStatCard({
    Key? key, required this.statistic, required this.statDescriptor
  }) : super(key: key);

  final String statistic;
  final String statDescriptor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: 152,
      padding:
      EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF22283D),
        borderRadius: BorderRadius.all(
          Radius.circular(3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Text(statistic,
                  style: Theme.of(context)
                      .textTheme
                      .headline4),
            ],
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Text(statDescriptor,
                  style: Theme.of(context)
                      .textTheme
                      .caption),
            ],
          ),
        ],
      ),
    );
  }
}