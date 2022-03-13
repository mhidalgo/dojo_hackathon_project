import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class LevelSelectCard extends StatefulWidget {
  LevelSelectCard({
    Key? key,
    this.levelMap, // one level document
    this.status = 'locked',
    required this.onPressAction,
  }) : super(key: key);

  final dynamic levelMap;
  final String status;
  var onPressAction;


  @override
  _LevelSelectCardState createState() => _LevelSelectCardState();
}

class _LevelSelectCardState extends State<LevelSelectCard> {
  @override
  void initState() {
    super.initState();

    /// determine if level card should display as completed, active, or locked
    determineCardState();
  }

  /// set default icon, box decoration, and selection state
  Icon currentIcon = lockedLevelIcon();
  BoxDecoration currentBoxDecoration = lockedLevelBoxDecoration();
  dynamic currentSelectionState = unSelectedLevelBoxDecoration();

  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************

  determineCardState() {
    if (widget.status == 'completed') {
      currentIcon = completedLevelIcon();
      currentBoxDecoration = completedLevelBoxDecoration();
    } else if (widget.status == 'active') {
      currentIcon = activeLevelIcon();
      currentBoxDecoration = activeLevelBoxDecoration();
    } else if (widget.status == 'locked') {
      currentIcon = lockedLevelIcon();
      currentBoxDecoration = lockedLevelBoxDecoration();
    }
  }

  /// ***********************************************************************
  /// View
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {

    /// store required values from levels map
    final String avatarImage = widget.levelMap['avatarImage'];
    final String avatarFirstLetter = widget.levelMap['opponentNickname'][0].toUpperCase();
    final int level = widget.levelMap['level'];
    final String opponentNickname = widget.levelMap['opponentNickname'];

    return Card(
      color: Colors.transparent,
      elevation: 8.0,
      borderOnForeground: false,
      child: Ink(
        height: 100,
        width: 232,
        decoration: currentBoxDecoration,
        child: InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.red.withOpacity(0.5),
          onTap: widget.onPressAction,
          child: Container(
            decoration: currentSelectionState,
            child: Container(
              height: 100,
              width: 232,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 8.0, bottom: 0.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text('LEVEL $level',
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                //padding: EdgeInsets.all(8.0),
                                child: currentIcon,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 4.0, right: 4.0, top: 0.0, bottom: 0.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: CustomCircleAvatar(
                                avatarFirstLetter: avatarFirstLetter,
                                radius: 16.0,
                                avatarImage: avatarImage,
                                enableAvatarImage: true,),
                            title: Text(opponentNickname),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ***********************************************************************
/// Visual options for the view
/// ***********************************************************************

/// level card backgrounds

BoxDecoration completedLevelBoxDecoration() {
  return BoxDecoration(
    color: primarySolidCardColor,
    borderRadius: borderRadius1(),
  );
}

BoxDecoration activeLevelBoxDecoration() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFB31217),
      Color(0xFFE52D27),
    ],

  ));
}

BoxDecoration lockedLevelBoxDecoration() {
  return BoxDecoration(
    borderRadius: borderRadius1(),
    color: inactiveSolidCardColor,
  );
}

/// level card selected / unselected decoration

BoxDecoration selectedLevelBoxDecoration() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
  );
}

BoxDecoration unSelectedLevelBoxDecoration() {
  return BoxDecoration(
    //borderRadius: cardBorderRadius(),
  );
}

/// Level card Icons

Icon completedLevelIcon() {
  return Icon(
    Icons.check_circle,
    color: Colors.red,
    size: 20.0,
  );
}

Icon activeLevelIcon() {
  return Icon(
    Icons.lock_open,
    color: Colors.white,
    size: 20.0,
  );
}

Icon lockedLevelIcon() {
  return Icon(
    Icons.lock,
    color: Colors.white,
    size: 20.0,
  );
}
