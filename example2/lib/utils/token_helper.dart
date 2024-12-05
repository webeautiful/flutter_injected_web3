import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_injected_web3/flutter_injected_web3.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';

class TokenHelper {
  static Future<String> signPersonalMessage(
      String privateKey, String data) async {
    try {
      EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
      Uint8List message =
          credentials.signPersonalMessageToUint8List(hexToBytes(data));
      String result = bytesToHex(message, include0x: true);
      return result;
    } catch (e) {
      return "";
    }
  }

  ///ETH网络ETH币的生成RAW的函数
  static Future<String> signEthTransaction(
      String privateKey, int? chainId, JsTransactionObject data) async {
    // int maxGas = int.parse(gasPrice) * int.parse(gasLimit);
    final transaction = Transaction(
      nonce: hexToDartInt(data.nonce ?? ''),
      gasPrice: EtherAmount.inWei(hexToInt(data.gasPrice ?? '')),
      maxGas: hexToDartInt(data.gasLimit ?? ''),
      to: EthereumAddress.fromHex(data.to ?? ''),
      value: EtherAmount.inWei(hexToInt(data.value ?? '')),
      data: Uint8List.fromList(utf8.encode(data.data ?? '0x0')),
    );
    final credentials = EthPrivateKey.fromHex(privateKey);
    final client = Web3Client('', Client());
    final signature = await client.signTransaction(credentials, transaction,
        chainId: chainId);
    return "0x${bytesToHex(signature)}";
  }

  static double calcGasFee(String gasLimitHex, String gasPriceHex) {
    BigInt gasLimit = hexToInt(gasLimitHex);
    BigInt gasPrice = hexToInt(gasPriceHex);
    BigInt gasFee = gasLimit * gasPrice;
    return gasFee / BigInt.from(10).pow(18);
  }
}
