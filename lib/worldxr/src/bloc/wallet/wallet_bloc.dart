import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial());

  String _address;
  List<dynamic> _holdings;
  String _ethBalance;

  get address => _address;
  get holdings => _holdings;
  get ethBalance => _ethBalance;

  setWalletInfo(String address, String ethBalance, List<dynamic> holdings) {
    _holdings = holdings;
    _ethBalance = ethBalance;
    _address = address;
  }

  @override
  Stream<WalletState> mapEventToState(
    WalletEvent event,
  ) async* {}
}
