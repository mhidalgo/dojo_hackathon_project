import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/moralis_poc/wallet_bloc.dart';
import 'package:dojo_app/screens/game/game_screen_wrapper.dart';
import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/screens/matches_A2P/matches_wrapper.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/web3_service.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/public_address_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../style/colors.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import '../../style/text_styles.dart';

class InsertTokenScreen extends StatefulWidget {
  InsertTokenScreen({required this.insertTokenScreenWrapperMap}) {
    //
  }

  final Map insertTokenScreenWrapperMap;

  @override
  _InsertTokenScreenState createState() => _InsertTokenScreenState();
}

class _InsertTokenScreenState extends State<InsertTokenScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Manage opacity of layer on top of background video
  String videoOpacity = 'medium';

  /// Unpack parameters passed in
  late String gameRulesID = widget.insertTokenScreenWrapperMap['gameRulesID'];
  late String userID = widget.insertTokenScreenWrapperMap['userID'];
  late Map gameInfo = widget.insertTokenScreenWrapperMap['gameMap'];
  late bool displayPlayGameButton = widget.insertTokenScreenWrapperMap['paymentReceived'];
  late String gameMode = gameInfo['gameMode'];

  DatabaseServices databaseServices = DatabaseServices();
  late Future<bool> displayButton;
  String dateForApi = '';


  //final _buttonController = StreamController<Future<bool>>();
  //Stream<Future<bool>> get showButtonStream => _buttonController.stream;
  //Sink<Future<bool>> get showButtonSink => _buttonController.sink;

  @override
  void initState() {
    super.initState();
    DateTime dateNow = DateTime.now().toUtc();
    DateTime startChallengeDate = DateTime(dateNow.year, dateNow.month, dateNow.day - (dateNow.weekday - 1)); //Always Monday

    if(startChallengeDate.month < 10){
      dateForApi = '${startChallengeDate.year}-0${startChallengeDate.month}-${startChallengeDate.day}';
    } else {
      dateForApi = '${startChallengeDate.year}-${startChallengeDate.month}-${startChallengeDate.day}';
    }

    displayButton = fetchTokenTransactions(dateForApi);
    //showButtonSink.add(displayButton);
    //timerTest();
    //fetchTokenTransactions();
  }

  @override
  void dispose() {
    printBig('Create Match Dispose Called', 'true');
    super.dispose();
    //_buttonController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()),
        (Route<dynamic> route) => false);
  }

  void setDisplayButton() {
    setState(() {
      displayPlayGameButton = true;
    });
  }

  void playGameButtonAction() {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            child: GameScreenWrapper(userID: userID, gameMode: gameMode, gameMap: gameInfo, groupID: 'xyz', id: gameInfo['id'])),
        (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************
/*
  void timerTest() async {
    Timer(Duration(seconds: 5), () {
      displayPlayGameButton = true;
      showButtonSink.add(displayPlayGameButton);
    });
  }*/

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    printBig('gameInfo', '$gameInfo');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'INSERT TOKENS'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('tap');
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.height) -
                      (MediaQuery.of(context).padding).top -
                      (MediaQuery.of(context).padding).bottom -
                      kToolbarHeight,
                  child: Stack(
                    children: <Widget>[
                      BackgroundTopImage(imageURL: 'images/castle.jpg'),
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                              height:150,
                              width: 150,
                              child: Image.asset('images/insert-coin.png')),
                        ],
                      ),*/
                      BackgroundOpacity(
                        opacity: 'high',
                      ),
                      //BackgroundTopGradient(),
                      Column(
                        children: <Widget>[
                          HostCard(headLine: 'INSERT TOKENS', bodyText: 'Pay 5 DOJO tokens to play'),
                          SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width) * .9,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: DisplayPublicAddress(address: '0x32667CeF42753.......Ff020004', title: 'Pay this Ethereum address'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FutureBuilder(
                              future: displayButton,
                              //initialData: true,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final showButton = snapshot.data;
                                  if (showButton == true) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        //SizedBox(height:200),
                                        HighEmphasisButtonWithAnimation(
                                          id: 1,
                                          title: 'PLAY GAME',
                                          onPressAction: () {
                                            playGameButtonAction();
                                          },
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              }),
/*                          displayPlayGameButton ? HighEmphasisButtonWithAnimation(
                            id: 1,
                            title: 'PLAY GAME',
                            onPressAction: () {
                              playGameButtonAction();
                            },
                          ) : Container(),*/
                          SizedBox(
                            height: 100,
                          ),
                          /*HighEmphasisButtonWithAnimation(
                            id: 1,
                            title: 'TEST',
                            onPressAction: () {
                              setDisplayButton();
                            },
                          ),*/
                          Container(
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 100,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ]),
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
