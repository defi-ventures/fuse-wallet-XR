part of 'wallet_bloc.dart';

class WalletState extends Equatable {
  final WalletObjectState walletObjectState;

  const WalletState._({this.walletObjectState});

  const WalletState.setWallet(WalletObjectState walletObjectState)
      : this._(walletObjectState: walletObjectState);

  const WalletState.initial() : this._(walletObjectState: null);

  @override
  List<Object> get props => [walletObjectState];
}
