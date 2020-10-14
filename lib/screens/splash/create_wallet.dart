import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/models/views/splash.dart';
import 'package:fusecash/screens/routes.gr.dart';
import 'package:fusecash/widgets/primary_button.dart';

class WarnBeforeReCreation extends StatefulWidget {
  @override
  _WarnBeforeReCreationState createState() => _WarnBeforeReCreationState();
}

class _WarnBeforeReCreationState extends State<WarnBeforeReCreation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimatoin;
  bool isPreloading = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    scaleAnimatoin =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext _context) {
    return ScaleTransition(
        scale: scaleAnimatoin,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Center(
            child: SvgPicture.asset(
              'assets/images/important.svg',
              width: 35,
              height: 35,
            ),
          ),
          content: Text(
              'Creating a new account will reset your existing account - are you sure you want to continue?'),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFF009DFF),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
              child: Text(I18n.of(context).yes, style: TextStyle(fontSize: 16)),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(false);
              },
              child: Text(I18n.of(context).no, style: TextStyle(fontSize: 16)),
            ),
          ],
        ));
  }
}

class CreateWallet extends StatefulWidget {
  @override
  _CreateWalletState createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {
  bool isPrimaryPreloading = false;
  bool isTransparentPreloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SplashViewModel>(
        distinct: true,
        converter: SplashViewModel.fromStore,
        builder: (_, viewModel) {
          return Container(
            padding: EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                PrimaryButton(
                  fontSize: 16,
                  labelFontWeight: FontWeight.normal,
                  disabled: false,
                  label: viewModel.isLoggedOut
                      ? I18n.of(context).login
                      : "Continue",
                  onPressed: () async {
                    if (viewModel.isLoggedOut) {
                      viewModel.loginAgain();
                      ExtendedNavigator.root.replace(Routes.homePage);
                    } else {
                      viewModel.setDeviceIdCall();
                      ExtendedNavigator.root.pushSignupScreen();
                    }
                  },
                  preload: false,
                ),
              ],
            ),
          );
        });
  }
}
