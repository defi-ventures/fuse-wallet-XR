class WalletObjectState {
  final String address;
  List<dynamic> holdings;
  String ethBalance;
  String get getAddress => address;

  WalletObjectState(this.address, {this.ethBalance, this.holdings});
}
