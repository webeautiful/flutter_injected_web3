import 'package:flutter_injected_web3/flutter_injected_web3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  String rpc = "https://polygon.llamarpc.com";
  int chainId = 137;

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: InjectedWebview(
          addEthereumChain: changeNetwork,
          requestAccounts: getAccount,
          signTransaction: signTransaction,
          signPersonalMessage: signPersonelMessage,
          isDebug: true,
          initialUrlRequest: URLRequest(
              url: WebUri(
                  'https://0xsequence.github.io/demo-dapp-web3modal')), //https://pancakeswap.finance/
          chainId: chainId,
          rpc: rpc,
        ),
      ),
    );
  }

  Future<String> changeNetwork(InAppWebViewController controller,
      JsAddEthereumChain data, int chainId) async {
    try {
      rpc = "https://rpc.ankr.com/eth";
      chainId = int.parse(data.chainId!);
    } catch (e) {
      debugPrint("$e");
    }
    return rpc;
  }

  Future<IncomingAccountsModel> getAccount(
      InAppWebViewController _, String ___, int __) async {
    //Credentials fromHex = EthPrivateKey.fromHex("Private key here");
    //final address = await fromHex.extractAddress();//address.toString()
    return IncomingAccountsModel(
        address: "0x389e8305cA85c153e0CA4f36E460bD0D63db8158",
        chainId: chainId,
        rpcUrl: rpc);
  }

  Future<String> signTransaction(
      InAppWebViewController _, JsTransactionObject data, int chainId) async {
    return "0x45fb0060681bf5d8ea675ab0b3f76aa15c84b172f2fb3191b7a8ceb1e6a7f372";
  }

  Future<String> signPersonelMessage(
      InAppWebViewController _, String data, int chainId) async {
    try {
      Credentials fromHex = EthPrivateKey.fromHex(
          "8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8");
      final sig = await fromHex.signPersonalMessage(hexToBytes(data));

      debugPrint("SignedTx ${sig}");
      return bytesToHex(sig, include0x: true);
    } catch (e) {
      debugPrint("$e");
    }
    return "";
  }
}
