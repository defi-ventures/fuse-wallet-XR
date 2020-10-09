import 'package:fusecash/worldxr/src/bloc/auth/auth_bloc.dart';
import 'package:fusecash/worldxr/src/config.dart';

import 'package:fusecash/worldxr/src/locator.dart';
import 'package:fusecash/worldxr/src/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class App extends StatefulWidget {
  App({Key key, this.config}) : super(key: key);
  final Config config;
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    locator.registerSingleton<Config>(widget.config);
    registerLocatorItems();
    BlocProvider.of<AuthBloc>(context).add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      home: HomePage(),
    );
  }
}
