import 'dart:convert';
import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';




class MintNft extends StatefulWidget {
  const MintNft({Key? key, required this.videoUrl
  }) : super(key: key);

  final String videoUrl;
  @override
  _MintNftState createState() => _MintNftState();
}

class _MintNftState extends State<MintNft> {

  Future<void> createNFT(String videoUrl) async {
    final response = await http.post(
      Uri.parse('https://api.nftport.xyz/v0/mints/easy/urls'),
      headers: <String, String>{
        'Authorization':'249a4ff4-846d-426a-9280-26c36a5952ca',
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{
        'chain': 'polygon',
        'name': 'Dojo NFTs',
        'description':'Sport NFTs of your best athletic feats',
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
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MINT YOUR NFT'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Text('Token name ${widget.videoUrl}',style: TextStyle(fontSize: 20)),
               HighEmphasisButton(title: 'MINT',
                    onPressAction: () async {
                    await createNFT(widget.videoUrl);
                    print('success');
                    }
                ),
              MediumEmphasisButton(title: 'EXIT', onPressAction: (){
                Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()),
                        (Route<dynamic> route) => false);
              },)
            ]
        ),
      ),
    );
  }
}
