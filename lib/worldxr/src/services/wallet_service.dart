
import 'package:dio/dio.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/wallet_object_state.dart';
import 'package:wallet_core/wallet_core.dart';

class WalletService {
  Web3 web3 = new Web3(approvalCallback);

  Future<void> setPrivateKey(String privateKey) {
    return web3.setCredentials(privateKey);
  }

  Future<String> _getWalletAddress() {
    return web3.getAddress();
  }

  Future<String> _getEthBalance(String address) async {
    EtherAmount etherAmount = await web3.getBalance(address: address);
    return etherAmount.getInEther.toString();
  }

  Future<WalletObjectState> retrieveWalletState(String key) async {
    try {
      // get wallet address
      String address = await _getWalletAddress();

      // create wallet state
      WalletObjectState walletState = WalletObjectState(address);

      // set wallet eth balance
      walletState.ethBalance = await _getEthBalance(address);

      // set wallet holdings
      Response response = await Dio().get("$serverIp/api/apk/walletinfo/$key");
      walletState.holdings = response.data[['tokenInfo']];

      return walletState;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

Future<bool> approvalCallback() async {
  return true;
}
