import 'dart:convert';
import 'dart:typed_data';

import 'package:example2/utils/token_helper.dart';
import 'package:example2/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_injected_web3/flutter_injected_web3.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(MaterialApp(
    title: 'demo',
    navigatorKey: navigatorKey, // 设置全局 Navigator
    home: const MainApp(),
  ));
}

BuildContext getGlobalContext() {
  return navigatorKey.currentState!.context;
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  late Map<int, IncomingAccountsModel> supportedNetworks;
  late IncomingAccountsModel currentNetwork;

  DappModel dappModel = DappModel(
      'https://0xzx.com/wp-content/uploads/2021/05/20210530-19.jpg', 'Unknown');

  @override
  void initState() {
    final List<IncomingAccountsModel> ethereumConfigs = [
      IncomingAccountsModel(
        address: '0x389e8305cA85c153e0CA4f36E460bD0D63db8158',
        chainId: 137,
        rpcUrl: 'https://polygon.llamarpc.com',
      ),
      IncomingAccountsModel(
        address: '0x389e8305cA85c153e0CA4f36E460bD0D63db8158',
        chainId: 1,
        rpcUrl: 'https://ethereum-rpc.publicnode.com',
      ),
      IncomingAccountsModel(
        address: "0x389e8305cA85c153e0CA4f36E460bD0D63db8158",
        chainId: 56,
        rpcUrl: "https://bsc-dataseed1.binance.org",
      ),
      IncomingAccountsModel(
        address: '0x389e8305cA85c153e0CA4f36E460bD0D63db8158',
        chainId: 97,
        rpcUrl: 'https://data-seed-prebsc-1-s3.binance.org:8545',
      )
    ];
    supportedNetworks = {
      for (var config in ethereumConfigs) config.chainId: config,
    };

    currentNetwork = ethereumConfigs[1];
    super.initState();
  }

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
        isDebug: false,
        // initialUrlRequest: URLRequest(
        //   url: WebUri('https://appkit-lab.reown.com/library/ethers-all/'),
        // ), //https://pancakeswap.finance/
        // initialUrlRequest: URLRequest(
        //   url: WebUri('https://0xsequence.github.io/demo-dapp-web3modal/'),
        // ),
        initialUrlRequest: URLRequest(
          url: WebUri('https://www.clicksx.im/web3_demo/?v=1.0.1'),
        ),
        chainId: currentNetwork.chainId,
        rpc: currentNetwork.rpcUrl,
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

  Future<IncomingAccountsModel> handleRequestAccounts(
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
      throw 'Request Canceled!';
    }
    return currentNetwork;
  }

  Future<String> handleSignPersonalMessage(
      InAppWebViewController _, data) async {
    final text = utf8.decode(hexToBytes(data));
    final message = """
      消息: $text \n
      数据: $data
      """;
    final result = await MyDialog.showConfirm(title: '请求签名', content: message);
    if (!result) {
      throw 'Signature Request Canceled!';
    }
    final password = await MyDialog.showInput();
    if (password != '123') throw 'Signature failure';
    const privateKey =
        '8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8';
    return TokenHelper.signPersonalMessage(privateKey, data);
  }

  Future<String> handleSignTransaction(
      InAppWebViewController _, JsTransactionObject data, int chainId) async {
    if (data.data == null) {
      // ETH交易
      return processEthTransaction(data, chainId);
    } else if (data.data!.startsWith('0xa9059cbb') &&
        data.data!.length >= 138) {
      // Token交易
      return processTokenTransaction(data, chainId);
    } else if (data.data!.startsWith('0x095ea7b3') &&
        data.data!.length >= 106) {
      // 交易授权
      return processTransactionApprove(data, chainId);
    } else {
      // 合约交互
      return processContractInteraction(data, chainId);
    }
  }

  Future<String> handleChangeNetwork(InAppWebViewController controller,
      JsAddEthereumChain data, int chainId) async {
    final toChainId = int.parse(data.chainId!);
    if (supportedNetworks[toChainId] == null) {
      throw '不支持该网络';
    }
    currentNetwork = supportedNetworks[chainId]!;
    return currentNetwork.rpcUrl;
  }

  // 交易确认处理逻辑 //
  Future<String> processEthTransaction(
      JsTransactionObject data, int chainId) async {
    double amount = BigInt.parse(data.value ?? '') / BigInt.from(10).pow(18);
    data.from = currentNetwork.address;
    // data.from =
    //     '0xa83114A443dA1CecEFC50368531cACE9F37fCCcb'; // 用于测试获取nonce, gasPrice, gasLimit值
    final client = Web3Client(currentNetwork.rpcUrl, Client());

    // fetch nonce
    if (data.nonce == null) {
      final nonce =
          await client.getTransactionCount(EthereumAddress.fromHex(data.from!));
      data.nonce = nonce.toRadixString(16);
    }

    // fetch gasPrice
    final gasPrice = await client.getGasPrice();
    String gasPriceHex = gasPrice.getInWei.toRadixString(16);
    data.gasPrice = gasPriceHex;

    // fetch gasLimit
    late BigInt gasLimit;
    String? errorMsg;
    try {
      gasLimit = await client.estimateGas(
        sender: EthereumAddress.fromHex(data.from!),
        to: EthereumAddress.fromHex(data.to!),
        value: EtherAmount.inWei(BigInt.parse(data.value ?? '')),
        data: data.data != null
            ? Uint8List.fromList(utf8.encode(data.data!))
            : Uint8List(0),
      );
    } catch (e) {
      errorMsg = e.toString();
    }
    if (errorMsg != null) {
      MyDialog.showError(errorMsg);
      throw errorMsg;
    }
    final gasLimitHex = gasLimit.toRadixString(16);
    // const gasLimitHex = '0xea60'; // 接口返回
    data.gasLimit = gasLimitHex;

    // calculate gas fee
    double gasFee = TokenHelper.calcGasFee(gasLimitHex, gasPriceHex);

    final message = """
        icon: ${dappModel.icon}\n
        title: ${dappModel.title}\n
        网络费: $gasFee ETH \n
        从: ${data.from} \n
        至: ${data.to} \n
        交易数额: $amount ETH
      """;
    final result = await MyDialog.showConfirm(title: 'ETH交易', content: message);
    if (!result) {
      throw 'Signature Request Canceled!';
    }
    final password = await MyDialog.showInput();
    if (password != '123') throw 'Signature failure';
    const privateKey =
        '8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8';
    return TokenHelper.signEthTransaction(privateKey, chainId, data);
  }

  Future<String> processTokenTransaction(
      JsTransactionObject data, int chainId) async {
    data.from = currentNetwork.address;
    // data.from = '0xa83114A443dA1CecEFC50368531cACE9F37fCCcb'; // 用于测试获取nonce, gasPrice, gasLimit值
    final client = Web3Client(currentNetwork.rpcUrl, Client());

    // fetch nonce
    if (data.nonce == null) {
      final nonce =
          await client.getTransactionCount(EthereumAddress.fromHex(data.from!));
      data.nonce = nonce.toRadixString(16);
    }

    // fetch gasPrice
    final gasPrice = await client.getGasPrice();
    String gasPriceHex = gasPrice.getInWei.toRadixString(16);
    data.gasPrice = gasPriceHex;

    // fetch gasLimit
    late BigInt gasLimit;
    String? errorMsg;
    try {
      gasLimit = await client.estimateGas(
        sender: EthereumAddress.fromHex(data.from!),
        to: EthereumAddress.fromHex(data.to!),
        value: EtherAmount.inWei(BigInt.parse(data.value ?? '')),
        data: data.data != null
            ? Uint8List.fromList(utf8.encode(data.data!))
            : Uint8List(0),
      );
    } catch (e) {
      errorMsg = e.toString();
    }
    if (errorMsg != null) {
      MyDialog.showError(errorMsg);
      throw errorMsg;
    }
    final gasLimitHex = gasLimit.toRadixString(16);
    // const gasLimitHex = '0xea60'; // 接口返回
    data.gasLimit = gasLimitHex;

    // calculate gas fee
    double gasFee = TokenHelper.calcGasFee(gasLimitHex, gasPriceHex);

    String recipient = "0x${data.data!.substring(34, 74)}";
    BigInt decimalValue =
        BigInt.parse(data.data!.substring(74, 138), radix: 16);
    int decimals = 18; // 接口返回
    double amount = decimalValue / BigInt.from(10).pow(decimals);
    final message = """
        icon: ${dappModel.icon}\n
        title: ${dappModel.title}\n
        网络费: $gasFee ETH \n
        从: ${data.from} \n
        转账地址: $recipient \n
        转账金额: $amount DAI\n
        数据: ${data.data}
      """;
    final result =
        await MyDialog.showConfirm(title: 'Token交易', content: message);
    if (!result) {
      throw 'Signature Request Canceled!';
    }
    final password = await MyDialog.showInput();
    if (password != '123') throw 'Signature failure';
    const privateKey =
        '8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8';
    return TokenHelper.signEthTransaction(privateKey, chainId, data);
  }

  Future<String> processTransactionApprove(
      JsTransactionObject data, int chainId) async {
    data.from = currentNetwork.address;
    // data.from = '0xa83114A443dA1CecEFC50368531cACE9F37fCCcb';  // 用于测试获取nonce, gasPrice, gasLimit值
    final client = Web3Client(currentNetwork.rpcUrl, Client());

    // fetch nonce
    if (data.nonce == null) {
      final nonce =
          await client.getTransactionCount(EthereumAddress.fromHex(data.from!));
      data.nonce = nonce.toRadixString(16);
    }

    // fetch gasPrice
    final gasPrice = await client.getGasPrice();
    String gasPriceHex = gasPrice.getInWei.toRadixString(16);
    data.gasPrice = gasPriceHex;

    // fetch gasLimit
    late BigInt gasLimit;
    String? errorMsg;
    try {
      gasLimit = await client.estimateGas(
        sender: EthereumAddress.fromHex(data.from!),
        to: EthereumAddress.fromHex(data.to!),
        value: EtherAmount.inWei(BigInt.parse(data.value ?? '')),
        data: data.data != null
            ? Uint8List.fromList(utf8.encode(data.data!))
            : Uint8List(0),
      );
    } catch (e) {
      errorMsg = e.toString();
    }
    if (errorMsg != null) {
      MyDialog.showError(errorMsg);
      throw errorMsg;
    }
    final gasLimitHex = gasLimit.toRadixString(16);
    // const gasLimitHex = '0xea60'; // 接口返回
    data.gasLimit = gasLimitHex;

    // calculate gas fee
    double gasFee = TokenHelper.calcGasFee(gasLimitHex, gasPriceHex);

    String spender = "0x${data.data!.substring(34, 74)}";
    BigInt allowance = BigInt.parse(data.data!.substring(74, 138), radix: 16);
    int decimals = 18; // 接口返回
    double amount = allowance / BigInt.from(10).pow(decimals);
    final message = """
        icon: ${dappModel.icon}\n
        title: ${dappModel.title}\n
        网络费: $gasFee ETH \n
        从: ${data.from} \n
        授权地址: $spender \n
        授权数额: $amount USDT \n
        数据: ${data.data}
      """;
    final result =
        await MyDialog.showConfirm(title: '请求Token授权', content: message);
    if (!result) {
      throw 'Signature Request Canceled!';
    }
    final password = await MyDialog.showInput();
    if (password != '123') throw 'Signature failure';
    const privateKey =
        '8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8';
    return TokenHelper.signEthTransaction(privateKey, chainId, data);
  }

  Future<String> processContractInteraction(
      JsTransactionObject data, int chainId) async {
    double amount = BigInt.parse(data.value ?? '') / BigInt.from(10).pow(18);
    data.from = currentNetwork.address;
    // data.from = '0xa83114A443dA1CecEFC50368531cACE9F37fCCcb'; // 用于测试获取nonce, gasPrice, gasLimit值
    final client = Web3Client(currentNetwork.rpcUrl, Client());

    // fetch nonce
    if (data.nonce == null) {
      final nonce =
          await client.getTransactionCount(EthereumAddress.fromHex(data.from!));
      data.nonce = nonce.toRadixString(16);
    }

    // fetch gasPrice
    final gasPrice = await client.getGasPrice();
    String gasPriceHex = gasPrice.getInWei.toRadixString(16);
    data.gasPrice = gasPriceHex;

    // fetch gasLimit
    // data.from = '0xa83114A443dA1CecEFC50368531cACE9F37fCCcb';
    late BigInt gasLimit;
    String? errorMsg;
    try {
      gasLimit = await client.estimateGas(
        sender: EthereumAddress.fromHex(data.from!),
        to: EthereumAddress.fromHex(data.to!),
        value: EtherAmount.inWei(BigInt.parse(data.value ?? '')),
        data: data.data != null
            ? Uint8List.fromList(utf8.encode(data.data!))
            : Uint8List(0),
      );
    } catch (e) {
      errorMsg = e.toString();
    }
    if (errorMsg != null) {
      MyDialog.showError(errorMsg);
      throw errorMsg;
    }
    final gasLimitHex = gasLimit.toRadixString(16);
    // const gasLimitHex = '0xea60'; // 接口返回
    data.gasLimit = gasLimitHex;

    // calculate gas fee
    double gasFee = TokenHelper.calcGasFee(gasLimitHex, gasPriceHex);

    final message = """
        icon: ${dappModel.icon}\n
        title: ${dappModel.title}\n
        网络费: $gasFee ETH \n
        从: ${data.from} \n
        合约地址: ${data.to} \n
        交易数额: $amount ETH\n
        数据: ${data.data}
      """;
    final result = await MyDialog.showConfirm(title: '合约交互', content: message);
    if (!result) {
      throw 'Signature Request Canceled!';
    }
    final password = await MyDialog.showInput();
    if (password != '123') throw 'Signature failure';
    const privateKey =
        '8ae0bfd5f1b40fc450077f702bfe152bf0d7ac53849d032cd55f4699a559fff8';
    return TokenHelper.signEthTransaction(privateKey, chainId, data);
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
