part of 'auth_bloc.dart';

enum AuthStatus { authenticated, unauthenticated, unknown, loading }

class AuthState extends Equatable {
  const AuthState._(
      {this.status = AuthStatus.unknown,
      this.user = User.empty,
      this.privateKey = ''});

  const AuthState.unknown() : this._();

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(User user, String privateKey)
      : this._(
            status: AuthStatus.authenticated,
            user: user,
            privateKey: privateKey);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated, privateKey: '');

  final AuthStatus status;
  final User user;
  final String privateKey;

  @override
  List<Object> get props => [status, user];
}
