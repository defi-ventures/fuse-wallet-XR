part of 'wallet_bloc.dart';

@immutable
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class SetWallet extends WalletEvent {
  final WalletObjectState walletObjectState;

  SetWallet(this.walletObjectState);

  @override
  List<Object> get props => [walletObjectState];
}
