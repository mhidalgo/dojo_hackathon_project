// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:intl/intl.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'dart:math'; // used for the random number generator
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class Web3Service {
  Web3Service() {
    // constructor
  }

  /// Create Credentials from private keys
  Credentials fromHex = EthPrivateKey.fromHex("b4e7827decc57c2f67dd3d3f5f62b883890ecff4c97adefb2d71e60815775184");

  /// Connect to RPC Server
  late var apiUrl = "https://ropsten.infura.io/v3/1e5bf73e36f04822a0fc51df918631fb";
  late var httpClient = Client();
  late var ethClient = Web3Client(apiUrl, httpClient);

  void sendEthereumTransaction({required String toAddress}) async {
    toAddress = '0x923C5D0e6A3a11A798aD3F05B16c7C715D1Bac38';
    await ethClient.sendTransaction(
        fromHex,
        Transaction(
          to: EthereumAddress.fromHex(toAddress),
          gasPrice: EtherAmount.inWei(BigInt.one),
          maxGas: 100000,
          value: EtherAmount.fromUnitAndValue(EtherUnit.szabo, 10),
        ),
        chainId: 3);

    printBig('transaction finished', 'true');
  }

  void checkBalance() async {
    // Derive public key from a private key:
    var address = await fromHex.extractAddress();
    printBig('public address:', '${address.hex}');

    // RPC Method to get balance
    EtherAmount balance = await ethClient.getBalance(address);
    printBig('Balance', '${balance.getValueInUnit(EtherUnit.ether)}');
  }
}
