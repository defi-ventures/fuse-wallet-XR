import 'dart:async';

import 'package:fusecash/worldxr/src/data/wallet_object_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletState.initial());

  @override
  Stream<WalletState> mapEventToState(
    WalletEvent event,
  ) async* {
    if (event is SetWallet) {
      yield WalletState.setWallet(event.walletObjectState);
    }
  }
}
