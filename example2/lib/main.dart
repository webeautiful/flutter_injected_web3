import 'dart:convert';

import 'package:example2/utils/token_helper.dart';
import 'package:example2/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_injected_web3/flutter_injected_web3.dart';
import 'package:web3dart/crypto.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(MaterialApp(
    title: 'demo',
    navigatorKey: navigatorKey, // 设置全局 Navigator
    home: MainApp(),
  ));
}

BuildContext getGlobalContext() {
  return navigatorKey.currentState!.context;
}

// ignore: must_be_immutable
class MainApp extends StatelessWidget {
  MainApp({super.key});
  final chainId = 137;
  // final chainId = 56;
  String rpc = "https://polygon.llamarpc.com";
  // String rpc = "https://bsc-dataseed1.binance.org";

  DappModel dappModel = DappModel(
      'https://0xzx.com/wp-content/uploads/2021/05/20210530-19.jpg', 'Unknown');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: InjectedWebview(
        requestAccounts: handleRequestAccounts,
        signPersonalMessage: handleSignPersonalMessage,
        signTransaction: handleSignTransaction,
        addEthereumChain: handleChangeNetwork,
        isDebug: true,
        initialUrlRequest: URLRequest(
          url: WebUri('https://0xsequence.github.io/demo-dapp-web3modal'),
        ), //https://pancakeswap.finance/
        // initialUrlRequest: URLRequest(
        //   url: WebUri('http://localhost:4000'),
        // ),
        chainId: chainId,
        rpc: rpc,
        onLoadStop: (controller, url) async {
          if (url == null) return;
          String baseUrl = url.origin;
          // 获取 favicon 的相对路径
          String? relativeIconPath =
              await controller.evaluateJavascript(source: """
                (() => {
                  let icon = document.querySelector("link[rel*='icon']");
                  return icon ? icon.getAttribute('href') : null;
                })();
                """);
          // 解析为绝对路径
          String? absoluteIconUrl;
          if (relativeIconPath != null) {
            absoluteIconUrl =
                Uri.parse(baseUrl).resolve(relativeIconPath).toString();
          }
          final faviconUrl = absoluteIconUrl ??
              'https://0xzx.com/wp-content/uploads/2021/05/20210530-19.jpg';
          // 更新页面标题
          String? title = await controller.evaluateJavascript(
              source: "document.querySelector('title')?.innerText");
          dappModel = DappModel(faviconUrl, title);
        },
      ),
    );
  }

  Future<IncomingAccountsModel?> handleRequestAccounts(
      InAppWebViewController _, String ___, int __) async {
    final result = await MyDialog.showConfirm(
      title: '申请授权',
      content: """
          正在申请访问你的钱包地址,你确认将钱包地址公开给此网站吗?\n
          icon: ${dappModel.icon}\n
          title: ${dappModel.title}\n
        """,
    );
    if (!result) {
      return null;
    }
    return IncomingAccountsModel(
      address: "0x389e8305cA85c153e0CA4f36E460bD0D63db8158",
      chainId: chainId,
      rpcUrl: rpc,
    );
  }

  Future<String> handleSignPersonalMessage(
      InAppWebViewController _, data) async {
    final message = utf8.decode(hexToBytes(data));
    final result = await MyDialog.showConfirm(title: '请求签名', content: message);
    if (!result) return '';
    final password = await MyDialog.showInput();
    if (password == null) return '';
    if (password != '123') return '';
    const privateKey =
        '8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8';
    return TokenHelper.signPersonalMessage(privateKey, data);
  }

  Future<String> handleSignTransaction(
      InAppWebViewController _, JsTransactionObject data, int chainId) async {
    return "0x45fb0060681bf5d8ea675ab0b3f76aa15c84b172f2fb3191b7a8ceb1e6a7f372";
  }

  Future<String> handleChangeNetwork(InAppWebViewController controller,
      JsAddEthereumChain data, int chainId) async {
    try {
      rpc = "https://rpc.ankr.com/eth";
      chainId = int.parse(data.chainId!);
    } catch (e) {
      debugPrint("$e");
    }
    return rpc;
  }
}

class DappModel {
  String id = "";
  String icon = "";
  String title = "";

  DappModel(String imageUrl, String? name) {
    icon = imageUrl;
    title = name ?? 'Unknown';
  }

  DappModel.fromJson(dynamic jsonStr) {
    if (jsonStr == null || jsonStr == {}) {
      return;
    }
    if (jsonStr["data"] != null) {
      jsonStr = jsonStr["data"];
    }
    id = jsonStr["id"].toString();
    icon = jsonStr["icon"] ?? "";
    title = jsonStr["nameLang"] ?? "";
  }
}
