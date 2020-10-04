part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthErrorState extends AuthState {}

class SignedUpState extends AuthState {
  final String privateKey;
  final User user;
  final WalletObjectState walletObjectState;

  SignedUpState(this.privateKey, this.user, this.walletObjectState);
}

class SignedOutState extends AuthState {}

class SignedInState extends AuthState {
  final User user;
  final String privateKey;
  final WalletObjectState walletObjectState;

  SignedInState(this.user, this.privateKey, this.walletObjectState);
}

class SignedInWithoutKeyState extends AuthState {
  final User user;

  SignedInWithoutKeyState(this.user);
}
