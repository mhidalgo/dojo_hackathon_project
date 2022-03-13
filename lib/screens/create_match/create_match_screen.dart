import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/screens/matches_A2P/matches_wrapper.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../style/colors.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'create_match_bloc.dart';

class CreateMatchScreen extends StatefulWidget {
  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in variables
  // the global values are set in the x_wrapper

  /// Instantiate bloc
  // majority of the logic is in this object
  late CreateMatchBloc createMatchBloc = CreateMatchBloc();

  /// Manage opacity of layer on top of background video
  String videoOpacity = 'medium';

  /// Set default values of drop down
  late String selectedValuePlayerOne = createMatchBloc.playerOneUserID; // 'AI22rzMxuphgmK5Zr8lVGht3O3D3';
  late String selectedValuePlayerTwo = createMatchBloc.playerTwoUserID; // 'AI22rzMxuphgmK5Zr8lVGht3O3D3';

  /// Values to pass to create match bloc
  late String playerOneUserID;
  late String playerTwoUserID;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    printBig('Create Match Dispose Called', 'true');
    super.dispose();
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

  createMatchButtonAction() async {
    await createMatchBloc.createMatchForMV();
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: MatchesWrapper()),
        (Route<dynamic> route) => false);
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
        title: PageTitle(title: 'ADMIN: CREATE MATCH'),
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
                      //BackgroundTopGradient(opacity: 0.2, stopStart: 0.2, stopEnd: 0.65),
                      BackgroundOpacity(opacity: 'high',),
                      //BackgroundTopGradient(),
                      Column(
                        children: <Widget>[
                          HostCard(
                              headLine: 'CREATE A NEW MATCH', bodyText: 'Choose two players to battle head to head in a 60 second pushup match'),
                          SizedBox(
                            height: 16,
                          ),
                          StreamBuilder<QuerySnapshot>(
                              // stream: FirebaseFirestore.instance.collection('users').snapshots(),
                              stream: createMatchBloc.users,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                return Container(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                                                child: Text(
                                                  "Player 1",
                                                ),
                                              )),
                                          new Expanded(
                                            flex: 4,
                                            child: DropdownButton<String>(
                                              value: selectedValuePlayerOne,
                                              isDense: true,
                                              items: snapshot.data!.docs.map((DocumentSnapshot document) {
                                                return DropdownMenuItem<String>(
                                                  value: document["User_ID"],
                                                  child: Text(document['Nickname']),
                                                );
                                              }).toList(),
                                              onChanged: (String? newSelectedValue) {
                                                printBig('newSelectedValue', '$newSelectedValue');
                                                setState(() {
                                                  selectedValuePlayerOne = newSelectedValue!;
                                                  playerOneUserID = newSelectedValue;
                                                });
                                                createMatchBloc.setPlayerOne = playerOneUserID;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                                                child: Text(
                                                  "Player 2",
                                                ),
                                              )),
                                          new Expanded(
                                            flex: 4,
                                            child: DropdownButton<String>(
                                              value: selectedValuePlayerTwo,
                                              isDense: true,
                                              items: snapshot.data!.docs.map((DocumentSnapshot document) {
                                                return DropdownMenuItem<String>(
                                                  value: document["User_ID"],
                                                  child: Text(document['Nickname']),
                                                );
                                              }).toList(),
                                              onChanged: (String? newSelectedValue) {
                                                printBig('newSelectedValue', '$newSelectedValue');
                                                setState(() {
                                                  selectedValuePlayerTwo = newSelectedValue!;
                                                  playerTwoUserID = newSelectedValue;
                                                });
                                                createMatchBloc.setPlayerTwo = playerTwoUserID;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          HighEmphasisButtonWithAnimation(
                            id: 1,
                            title: 'CREATE THE MATCH',
                            onPressAction: () {
                              createMatchButtonAction();
                            },
                          ),
                          SizedBox(
                            height: 100,
                          ),
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

/*
class CustomDropDownButton extends StatefulWidget {
  const CustomDropDownButton({Key? key, required this.snapshot, required this.selectedValue, required this.userID, required this.createMatchBloc}) : super(key: key);

  final QuerySnapshot snapshot;
  final String selectedValue;
  final String userID;
  final CreateMatchBloc createMatchBloc;

  @override
  _CustomDropDownButtonState createState() => _CustomDropDownButtonState();
}


class _CustomDropDownButtonState extends State<CustomDropDownButton> {
  late String selectedValue = widget.selectedValue;
  late var snapshot = widget.snapshot;
  late String userID;
  late CreateMatchBloc createMatchBloc;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedValue,
      isDense: true,
      hint: Text('LFG'),
      items: snapshot.data!.docs.map((DocumentSnapshot document) {
        return DropdownMenuItem<String>(
          value: document["User_ID"],
          child: Text(document['Nickname']),
        );
      }).toList(),
      onChanged: (String? newSelectedValue) {
        printBig('newSelectedValue', '$newSelectedValue');
        Map player = {'userID': userID, 'nickname': selectedValue};
        createMatchBloc.setPlayerOne(player);
        setState(() {
          selectedValue = newSelectedValue!;
          userID = newSelectedValue;
        });
      },
    );
  }
}
*/

