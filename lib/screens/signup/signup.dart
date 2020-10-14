import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/models/views/onboard.dart';
import 'package:fusecash/style/style.dart';
import 'package:fusecash/utils/constans.dart';
import 'package:fusecash/widgets/main_scaffold.dart';
import 'package:fusecash/widgets/snackbars.dart';
import 'package:fusecash/worldxr/src/constants.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  void onPressed(Function(Verifier) verifierSignUp, Verifier verifier) {
    try {
      verifierSignUp(verifier);
    } catch (e) {
      transactionFailedSnack(I18n.of(context).invalid_number,
          title: I18n.of(context).something_went_wrong,
          duration: Duration(seconds: 3),
          context: context,
          margin: EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 120));
    }
  }

  @override
  Widget build(BuildContext context) {
    Segment.screen(screenName: '/signup-screen');
    return MainScaffold(
      withPadding: true,
      gradient: LinearGradient(colors: [
        AppColors.dark_blue,
        AppColors.purple,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/gofindxr_logo.png',
            height: 70,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 20.0, right: 20.0, bottom: 40.0, top: 40.0),
          child: Text("Welcome To WorldXR",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.normal,
              )),
        ),
        Center(
          child: Column(
            children: [
              StoreConnector<AppState, OnboardViewModel>(
                  distinct: true,
                  onWillChange: (previousViewModel, newViewModel) {
                    if (previousViewModel.signupException !=
                            newViewModel.signupException &&
                        newViewModel.signupException.runtimeType ==
                            FirebaseAuthException) {
                      transactionFailedSnack(
                          newViewModel.signupException.message,
                          title: newViewModel.signupException.code,
                          duration: Duration(seconds: 3),
                          context: context,
                          margin: EdgeInsets.only(
                              top: 8, right: 8, left: 8, bottom: 120));
                      Future.delayed(Duration(seconds: intervalSeconds), () {
                        newViewModel.resetErrors();
                      });
                    }
                  },
                  converter: OnboardViewModel.fromStore,
                  builder: (_, viewModel) => Center(
                          child: Column(
                        children: [
                          GoogleSignInButton(
                              text: "Continue With Google",
                              onPressed: () {
                                onPressed(
                                    viewModel.verifierSignUp, Verifier.google);
                              }),
                          if (Platform.isIOS)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: AppleSignInButton(
                                  text: "Continue With Apple",
                                  onPressed: () {
                                    onPressed(viewModel.verifierSignUp,
                                        Verifier.apple);
                                  }),
                            ),
                        ],
                      ))),
            ],
          ),
        ),
      ],
      /*  footer: Padding(
          padding: EdgeInsets.only(top: 10, left: 30, right: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              width: 2.0)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: CountryCodePicker(
                            onChanged: (_countryCode) {
                              setState(() {
                                countryCode = _countryCode;
                              });
                              Segment.track(
                                  eventName: 'Wallet: country code selected',
                                  properties: Map.from({
                                    'Dial code': _countryCode.dialCode,
                                    'County code': _countryCode.code,
                                  }));
                            },
                            searchStyle: TextStyle(fontSize: 18),
                            showFlag: true,
                            initialSelection: countryCode.code,
                            showCountryOnly: false,
                            textStyle: TextStyle(fontSize: 18),
                            alignLeft: false,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                        Container(
                          height: 35,
                          width: 1,
                          color: Color(0xFFc1c1c1),
                          margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: phoneFocus,
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            validator: (String value) => value.isEmpty
                                ? "Please enter mobile number"
                                : null,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                hintText: I18n.of(context).phoneNumber,
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.0),
                StoreConnector<AppState, OnboardViewModel>(
                    distinct: true,
                    onWillChange: (previousViewModel, newViewModel) {
                      if (previousViewModel.signupException !=
                              newViewModel.signupException &&
                          newViewModel.signupException.runtimeType ==
                              FirebaseAuthException) {
                        transactionFailedSnack(
                            newViewModel.signupException.message,
                            title: newViewModel.signupException.code,
                            duration: Duration(seconds: 3),
                            context: context,
                            margin: EdgeInsets.only(
                                top: 8, right: 8, left: 8, bottom: 120));
                        Future.delayed(Duration(seconds: intervalSeconds), () {
                          newViewModel.resetErrors();
                        });
                      }
                    },
                    converter: OnboardViewModel.fromStore,
                    builder: (_, viewModel) => Center(
                          child: PrimaryButton(
                            label: I18n.of(context).next_button,
                            fontSize: 16,
                            labelFontWeight: FontWeight.normal,
                            onPressed: () {
                              onPressed(viewModel.signUp);
                            },
                            preload: viewModel.isLoginRequest,
                          ),
                        ))
              ],
            ),
          ),) */
    );
  }
}
