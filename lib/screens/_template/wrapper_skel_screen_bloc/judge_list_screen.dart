import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/open_challenge_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'judge_list_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  //print(message.notification!.title);
}

//ignore: must_be_immutable
class JudgeListScreen extends StatefulWidget {
  JudgeListScreen() {
    // Constructor
  }

  @override
  _JudgeListScreenState createState() => _JudgeListScreenState();
}

class _JudgeListScreenState extends State<JudgeListScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in variables
  // the global values are set in the levels_wrapper
  // String nickname = globals.judgeListWrapperMap['nickname'];
  // String userID = globals.judgeListWrapperMap['userID'];

  /// Declare variable where mot of the logic is managed for this page
  // majority of the logic is in this object
  late JudgeListBloc judgeListController;

  @override
  void initState() {
    super.initState();

    /// Instantiate controller for this Game Mode page
    judgeListController = JudgeListBloc(userID: globals.dojoUser.uid);
  }

  @override
  void dispose() {
    printBig('Judge List Dispose Called', 'true');
    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    print('do nothing');
  }

  menuAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Menu()));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'DOJO'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            print('tap');
            menuAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(0),
            child: Column(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.height) -
                      (MediaQuery.of(context).padding).top -
                      (MediaQuery.of(context).padding).bottom,
                  child: Stack(
                    children: <Widget>[
                      Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
                      Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            HostCard(
                                headLine: 'Rate player performance',
                                bodyText:
                                    'Watch games to rate their pushup form so they know if they\'re doing it right or wrong.'),
                            SizedBox(height: 16),
                            Divider(height: 1.0, thickness: 1.0, indent: 16.0, endIndent: 16.0),
                            SizedBox(height: 16),
                            SizedBox(height: 100, child: MatchesOpenForJudging()),
                            /*StreamBuilder<Map>(
                                stream: judgeListController.matchesOpenForJudgingStream,
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    final listOfMatchesOpenForJudging = snapshot.data as List;
                                    return Container();
                                  } else {
                                    return Container();
                                  }
                                }),*/
                          ],
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
    );
    // top module
  }
}

class MatchesOpenForJudging extends StatefulWidget {
  @override
  _MatchesOpenForJudgingState createState() => _MatchesOpenForJudgingState();
}

class _MatchesOpenForJudgingState extends State<MatchesOpenForJudging> {
  DatabaseServices databaseServices = DatabaseServices();
  late final Stream<QuerySnapshot> _matchesOpenForJudging =
      databaseServices.fetchMatchesForJudgingStream('${globals.dojoUser.uid}');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _matchesOpenForJudging,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Contact cat support', style: Theme.of(context).textTheme.bodyText1);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Analyzing matches...', style: Theme.of(context).textTheme.bodyText1);
        }

        return ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return OpenChallengeCard(
              avatarImage: 'images/avatar-blank.png',
              avatarFirstLetter: 'M',
              title: 'title',
              opponentName: 'opponent name',
              gameID: 'gameID',
              gameTypeID: 0,
            );
          }).toList(),
        );
      },
    );
  }
}
