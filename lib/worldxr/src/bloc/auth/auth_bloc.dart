import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusecash/worldxr/src/bloc/wallet/wallet_bloc.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/user.dart';
import 'package:fusecash/worldxr/src/data/wallet_object_state.dart';
import 'package:fusecash/worldxr/src/locator.dart';
import 'package:fusecash/worldxr/src/services/auth_service.dart';
import 'package:fusecash/worldxr/src/services/wallet_service.dart';
import 'package:meta/meta.dart';
import 'package:local_auth/local_auth.dart';
import 'package:torus_direct/torus_direct.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    @required WalletBloc walletBloc,
  })  : assert(walletBloc != null),
        _walletBloc = walletBloc,
        super(AuthState.unknown());

  WalletBloc _walletBloc;
  AuthService get _authService => locator.get();
  WalletService get _walletService => locator.get();
  LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    String privateKey;
    if (event is AppStarted) {
      // prompt user with fingerprint to get access to saved private key if not null

      User user = await _authService.getUser();

      if (_authService.readPrivateKey() != null && user != null) {
        bool canCheckBiometrics;
        try {
          canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
        } catch (e) {
          canCheckBiometrics = false;
        }
        if (canCheckBiometrics) {
          privateKey = await fingerPrintOrFaceIDForKey();
        } else {
          //TODO: authenticate with passcode when package updates
          privateKey = null;
        }

        if (privateKey != null) {
          await _walletService.setPrivateKey(privateKey);

          WalletObjectState walletObjectState =
              await _walletService.retrieveWalletState(privateKey);

          _walletBloc.add(SetWallet(walletObjectState));

          yield AuthState.authenticated(user, privateKey);
        }
      } else {
        _authService.clearStoredData();
        yield AuthState.unauthenticated();
        return;
      }
    }
    if (event is SignInWithVerifier) {
      // set Torus verifier details

      setTorusVerifierDetails(event.verifier);

      // trigger Torus Login
      Map<dynamic, dynamic> loginInfo = await TorusDirect.triggerLogin();

      // save private key to secure storage (keychain for ios, keystore for android)
      await _authService.storePrivateKey(loginInfo['privateKey']);
      String privateKey = await _authService.readPrivateKey();

      // TODO: verify email is saved in backend

      WalletObjectState walletObjectState =
          await _walletService.retrieveWalletState(privateKey);

      _walletBloc.add(SetWallet(walletObjectState));

      yield AuthState.authenticated(
          User(email: loginInfo['email'], imageUrl: loginInfo['picture']),
          privateKey);
    }

    if (event is SignOut) {
      await _authService.clearStoredData();
      yield AuthState.unauthenticated();
    }

    if (event is SignUpWithVerifier) {
      yield AuthState.loading();
      print("Signing up");
      // set Torus verifier details
      setTorusVerifierDetails(event.verifier);

      // trigger Torus Login
      Map<dynamic, dynamic> loginInfo = await TorusDirect.triggerLogin();
      print(loginInfo);

      String privateKey = loginInfo['privateKey'];
      await _walletService.setPrivateKey(privateKey);

      // save private key to secure storage (keychain for ios, keystore for android)

      await _authService.storePrivateKey(privateKey);

      User user =
          User(email: loginInfo['email'], imageUrl: loginInfo['picture']);

      await _authService.storeUser(user);

      WalletObjectState walletObjectState =
          await _walletService.retrieveWalletState(privateKey);

      _walletBloc.add(SetWallet(walletObjectState));
      // Save user info to backend
      int resStatusCode = await _authService.signUpWithVerifier(
          loginInfo['email'], loginInfo['id'], "google");
      if (resStatusCode != 200) {
        return;
      }

      yield AuthState.authenticated(user, privateKey);
    }
  }

  fingerPrintOrFaceIDForKey() async {
    List<BiometricType> availableBiometrics =
        await _localAuthentication.getAvailableBiometrics();

    bool authenticated;

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        authenticated = await _localAuthentication.authenticateWithBiometrics(
            localizedReason: 'Scan your Face ID to authenticate',
            useErrorDialogs: true,
            stickyAuth: true);
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        authenticated = await _localAuthentication.authenticateWithBiometrics(
            localizedReason: 'Scan your fingerprint to authenticate',
            useErrorDialogs: true,
            stickyAuth: true);
      }
    }

    if (authenticated) {
      return await _authService.readPrivateKey();
    }
    return null;
  }
}

setTorusVerifierDetails(Verifier verifier) {
  print(verifier.toString());
  switch (verifier) {
    case Verifier.google:
      TorusDirect.setVerifierDetails(
          LoginType.installed.value,
          VerifierType.singleLogin.value,
          "tokenizer-google-ios",
          "653095671042-san67chucuujmjoo218khq2rb92bh80d.apps.googleusercontent.com",
          LoginProvider.google.value,
          "tokenizer-google-ios",
          "com.googleusercontent.apps.653095671042-san67chucuujmjoo218khq2rb92bh80d:/oauthredirect");
      break;
    case Verifier.facebook:
      break;
    case Verifier.apple:
      break;
  }
}
