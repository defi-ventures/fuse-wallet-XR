import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:fusecash/worldxr/src/bloc/auth/auth_bloc.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/ui/style.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthBloc _authBloc;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    _authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        backgroundColor: AppColors.login_background,
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome to WorldXR",
                      style:
                          TextStyle(color: AppColors.blue_grey, fontSize: 22),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: GoogleSignInButton(
                              textStyle: TextStyle(color: AppColors.blue_grey),
                              text: "Continue With Google",
                              onPressed: () {
                                _authBloc
                                    .add(SignUpWithVerifier(Verifier.google));
                              }),
                        ),
                        if (Platform.isIOS)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: AppleSignInButton(
                                textStyle:
                                    TextStyle(color: AppColors.blue_grey),
                                text: "Continue With Apple",
                                onPressed: () {
                                  _authBloc
                                      .add(SignInWithVerifier(Verifier.apple));
                                }),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Or",
                              style: TextStyle(color: AppColors.blue_grey)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "By logging in you accept the Terms and Conditions",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.blue_grey, fontSize: 12),
                      ),
                    )
                  ])),
        ));
  }
}
