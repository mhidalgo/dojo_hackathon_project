import 'dart:convert';
import 'dart:io';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:http/http.dart' as http;
import 'package:dojo_app/moralis_poc/wallet_model.dart';

//MainNet - eth balance (Test wallet)
Future<WalletBalance> fetchWalletBalanceMainNet() async {
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/0xCbE268287CB39Ac33F1bcF92DE590000bb3f0415/balance?chain=eth'),
       headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
       );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WalletBalance.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

//TestNet - DOJO Token balance
Future<TokenData> fetchTokenDataTestNet() async {
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/0x80a3fD1F1fFe4aE862693112675C34726254ABA0/erc20?chain=ropsten&token_addresses=0x9abc4af7109197f360c83367b4a45054d37041ab'),
      headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return TokenData.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<bool> fetchTokenTransactions(String date) async {
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/0x32667CeF4275373FF346EE75373E5305Ff020004/erc20/transfers?chain=ropsten&from_date=$date'),
      headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
  );

  if (response.statusCode == 200) {

    var results = jsonDecode(response.body);

    var onlyPlayerTransactions = results['result'];
    print(onlyPlayerTransactions);

    List transactions = [];
    var transactionAmount;


    if(onlyPlayerTransactions.length > 1) {
      for (var i = 0; i < onlyPlayerTransactions.length - 1; i++) {
        if (onlyPlayerTransactions[i]['from_address'] ==
            '0xcbe268287cb39ac33f1bcf92de590000bb3f0415') {
          transactionAmount =
              (BigInt.parse(onlyPlayerTransactions[i]['value'])) /
                  BigInt.from(1000000000000000000);
          transactions.add(transactionAmount);
        }
      }
        var finalAmount = transactions.reduce((a, b) => a + b);
        print('The players transaction to Dojo Wallet: $onlyPlayerTransactions');
        print('THE AMOUNT TOKENS DEPOSITED IS: $finalAmount');
        if(finalAmount > 5) {
          return true;
        } else {
          return false;
        }
      } else {
      if (onlyPlayerTransactions[0]['from_address'] == '0xcbe268287cb39ac33f1bcf92de590000bb3f0415') {
        transactionAmount =
            (BigInt.parse(onlyPlayerTransactions[0]['value'])) /
                BigInt.from(1000000000000000000);
        transactions.add(transactionAmount);
        if(transactionAmount > 5) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }

}

