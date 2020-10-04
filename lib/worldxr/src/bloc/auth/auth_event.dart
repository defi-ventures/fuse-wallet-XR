part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class SignUpWithVerifier extends AuthEvent {
  final Verifier verifier;

  SignUpWithVerifier(this.verifier);
}

class SignInWithVerifier extends AuthEvent {
  final Verifier verifier;

  SignInWithVerifier(this.verifier);
}

class SignOut extends AuthEvent {}

class AppStarted extends AuthEvent {}
