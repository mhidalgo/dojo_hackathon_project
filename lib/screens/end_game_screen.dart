import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'game_modes/game_modes_wrapper.dart';






class EndGame extends StatefulWidget {
  const EndGame({Key? key}) : super(key: key);

  @override
  _EndGameState createState() => _EndGameState();
}

class _EndGameState extends State<EndGame> {

  String winnerUserId = '';
  String score = '';
  String playerNickname = 'TBD';
  bool winnerDetermined = false;

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

  Future<Map> determineWinner() async{
     final scoreQuery = await FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .get();

     var result = scoreQuery.docs.first.data();

     final Map winnerData = {
       'userID': result['userID'],
       'score': result['score'],
       'ipfsUrl': result['ipfsUrl'],
       'id':result['id'],
       'playerNickname':result['playerNickname']
     };

     winnerUserId = winnerData['userID'];
     score =winnerData['score'].toString();
     playerNickname = winnerData['playerNickname'];
     winnerDetermined = true;
     print(winnerData);
     return winnerData;
  }

  Future <void> updateLeaderBoard(String id) async {

    await FirebaseFirestore.instance.collection('leaderboard').doc(id).update(
      {'leaderboardStatus': 'winner'}
    ).then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));

  }

  Future<void> createNFT(String videoUrl) async {
    final response = await http.post(
      Uri.parse('https://api.nftport.xyz/v0/mints/easy/urls'),
      headers: <String, String>{
        'Authorization':'249a4ff4-846d-426a-9280-26c36a5952ca',
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{
        'chain': 'rinkeby',
        'name': 'Dojo NFT',
        'description':'Congrats you won the weekly challenge!',
        'file_url':videoUrl,
        'mint_to_address': '0xCbE268287CB39Ac33F1bcF92DE590000bb3f0415'
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      print(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('Failed to mint.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'ADMIN: END GAME'),
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
          child: Column(
            children: <Widget> [
              SizedBox(
                width: double.infinity,
                height: (MediaQuery.of(context).size.height) -
                    (MediaQuery.of(context).padding).top -
                    (MediaQuery.of(context).padding).bottom -
                    kToolbarHeight,
                child:Stack(
                  children: <Widget>[
                    BackgroundTopImage(imageURL: 'images/castle.jpg'),
                    BackgroundOpacity(opacity: 'high',),
                    Column(
                      children:<Widget> [
                        HostCard(headLine: 'End The Match', bodyText: 'End Game and declare winner to mint NFT'),
                        SizedBox(height: 20,),
                        Text('The winner is: $playerNickname',style: TextStyle(fontSize: 20),),
                        SizedBox(height: 10),
                        winnerDetermined? Text('with a score of $score',style:TextStyle(fontSize: 20)):Container(),
                        SizedBox(height: 20),
                        HighEmphasisButton(title: 'End Match',
                            onPressAction: () async {
                              Map result = await determineWinner();
                              await updateLeaderBoard(result['id']);
                              await createNFT(result['ipfsUrl']);
                              setState(() {

                              });
                            }
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
