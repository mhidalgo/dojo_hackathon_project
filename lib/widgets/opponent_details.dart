import 'package:flutter/material.dart';
import 'circle_avatar.dart';

//ignore: must_be_immutable
class OpponentDetails extends StatefulWidget {
  OpponentDetails({
    Key? key,
    this.levelMap,
    this.avatarImage = 'images/avatar-blank.png',
    this.avatarFirstLetter = 'X',
    this.opponentNickname = 'Diamond Hands Long Nickname',
    this.opponentRepCount = 10,
    this.opponentLocation = 'New York, NY',
    this.opponentNotes = 'Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum',
  }) : super(key: key);

  final dynamic levelMap;
  final String avatarImage;
  final String avatarFirstLetter;
  final String opponentNickname;
  final int opponentRepCount;
  final String opponentLocation;
  final String opponentNotes;

  @override
  _OpponentDetailsState createState() => _OpponentDetailsState();
}

class _OpponentDetailsState extends State<OpponentDetails> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this, value: 0.0);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// store required fields
    final dynamic opponentDetailsMap = widget.levelMap;
    final String avatarImage = widget.levelMap['avatarImage'];
    final String avatarFirstLetter = widget.levelMap['opponentNickname'][0].toUpperCase();
    final String opponentNickname = widget.levelMap['opponentNickname'];
    final int opponentRepCount = widget.levelMap['levelGoal'];
    final String opponentLocation = widget.levelMap['opponentLocation'];
    final String opponentNotes = widget.levelMap['opponentNotes'];

    return ScaleTransition(
      scale: _animation,
      child: Container(
        height: 235,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // left column containing avatar
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                children: [
                  // avatar
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 16.0),
                    child: CustomCircleAvatar(
                      avatarFirstLetter: avatarFirstLetter,
                      radius: 32.0,
                      avatarImage: (avatarImage),
                      enableAvatarImage: true,
                    ),
                  ),
                ],
              ),
            ),
            // right column containing text
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // opponent name
                  Text('OPPONENT',
                      style: Theme.of(context)
                          .textTheme
                          .caption),
                  Text(opponentNickname,
                      style: Theme.of(context)
                          .textTheme
                          .headline5),
                  SizedBox(height: 16),
                  // rep count, Win/Loss
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      // rep count
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('REP COUNT',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption),
                          Text('$opponentRepCount',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1),
                          SizedBox(height: 16),
                        ],
                      ),
                      // Location
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('LOCATION',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption),
                          Text(opponentLocation,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1),
                          SizedBox(height: 16),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // note
                  Text('NOTE',
                      style: Theme.of(context)
                          .textTheme
                          .caption),
                  Text(opponentNotes,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}