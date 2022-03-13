import 'package:dojo_app/moralis_poc/moralis_api_test_screen.dart';
import 'package:dojo_app/nftport_poc/nftport_video_screen.dart';
import 'package:dojo_app/screens/end_game_screen.dart';
import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/screens/judge_list/judge_list_screen.dart';
import 'package:dojo_app/screens/create_match/create_match_screen.dart';
import 'package:dojo_app/screens/judge_list/judge_list_wrapper.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:dojo_app/services/database.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../style/colors.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/mlKitPoc/computer_vision_poc.dart';

/// Simple template that can be starting point for any Screen.

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  var databaseService = DatabaseService(uid: globals.dojoUser.uid);
  late Future<String> nickname;
  final AuthService _auth = AuthService();

  // Manage admin view
  bool enableAdminView = false;

  @override
  void initState() {
    super.initState();

    // get nickname to display on UI
    nickname = databaseService.getNickname(globals.dojoUser.uid);

    // determine if admin view should be enabled
    if (globals.dojoUser.uid == constants.admin1 ||
        globals.dojoUser.uid == constants.admin2 ||
        globals.dojoUser.uid == constants.admin3 ||
        globals.dojoUser.uid == constants.admin4 ||
        globals.dojoUser.uid == constants.admin5) {
      enableAdminView = true;
    }
  }

  backButtonAction() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        //title: PageTitle(title: 'TURN BASED 2 PLAYER'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              CustomCircleAvatar(avatarFirstLetter: globals.nickname[0].toUpperCase()),
                              SizedBox(width: 16),
                              Text(globals.nickname, style: Theme.of(context).textTheme.headline4),
                            ],
                          ),
                          SizedBox(
                            height: 32,
                          ),
                          enableAdminView ? GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: CreateMatchScreen()), (Route<dynamic> route) => false);
                              print('tap');
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.new_label,
                                    size: 32),
                                SizedBox(width: 16),
                                Text('Create New Match', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ) : Container(),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()), (Route<dynamic> route) => false);
                              print('tap');
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.new_label,
                                    size: 32),
                                SizedBox(width: 16),
                                Text('Players', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          enableAdminView ? GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: EndGame()), (Route<dynamic> route) => false);
                              print('tap');
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.new_label,
                                    size: 32),
                                SizedBox(width: 16),
                                Text('End Game', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ) : Container(),
                          SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: JudgeListScreen()), (Route<dynamic> route) => false);
                              print('tap');
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.sports_score_outlined,
                                    size: 36),
                                SizedBox(width: 16),
                                Text('Judge Completed Matches', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                          SizedBox(height: 16),
                          enableAdminView ? GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: ComputerVisionTest()), (Route<dynamic> route) => false);

                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                FaIcon(FontAwesomeIcons.database, size: 32),
                                SizedBox(width: 16),
                                Text('MLKit Test', style: Theme.of(context).textTheme.bodyText1)
                              ],
                            ),
                          ) : Container(),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: MoralisApi()), (Route<dynamic> route) => false);

                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                FaIcon(FontAwesomeIcons.bitcoin, size: 32),
                                SizedBox(width: 16),
                                Text('Moralis API', style: Theme.of(context).textTheme.bodyText1)
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: VideoNft()), (Route<dynamic> route) => false);

                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                FaIcon(FontAwesomeIcons.ethereum, size: 32),
                                SizedBox(width: 16),
                                Text('Video NFT Mint', style: Theme.of(context).textTheme.bodyText1)
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              var url = "https://twitter.com/dojothegame";
                              if (await canLaunch(url)) {
                                await launch(url, forceWebView: false);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                FaIcon(FontAwesomeIcons.twitter, size: 32),
                                SizedBox(width: 16),
                                Text('Twitter', style: Theme.of(context).textTheme.bodyText1)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var url = "https://docs.google.com/forms/d/e/1FAIpQLSfMh8UU3IcrJpeNfSPbfibHKWEpr67c74akx0Rng-tq7ShLxg/viewform";
                              if (await canLaunch(url)) {
                                await launch(url, forceWebView: false, enableJavaScript: false);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.feedback,
                                    size: 32),
                                SizedBox(width: 16),
                                Text('Share your feedback', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Wrapper()), (Route<dynamic> route) => false);
                              await _auth.signOut();
                              print('tap');
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.logout,
                                    size: 32),
                                SizedBox(width: 16),
                                Text('Log out', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // top module
  }
}
