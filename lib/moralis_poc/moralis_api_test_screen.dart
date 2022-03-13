import 'package:dojo_app/moralis_poc/wallet_bloc.dart';
import 'package:dojo_app/moralis_poc/wallet_model.dart';
import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';





class MoralisApi extends StatefulWidget {
  const MoralisApi({Key? key}) : super(key: key);

  @override
  _MoralisApiState createState() => _MoralisApiState();
}

class _MoralisApiState extends State<MoralisApi> {
  //late Future<WalletBalance> futureWallet;
  late Future<TokenData> futureToken;


  @override
  void initState() {
    super.initState();
    //futureWallet = fetchWalletBalanceMainNet();
    futureToken = fetchTokenDataTestNet();
    //fetchTokenTransactions();

  }

  backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()),
            (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print('tap');
              backButtonAction();
            },
          ),
        ),
        body: Center(
          child: FutureBuilder<TokenData>(
            future: futureToken,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Token name ${snapshot.data!.name}',style: TextStyle(fontSize: 20)),
                    Text('Token balance ${snapshot.data!.balance}',style: TextStyle(fontSize: 16)),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}