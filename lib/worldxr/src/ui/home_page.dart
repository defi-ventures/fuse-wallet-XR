
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:fusecash/worldxr/src/bloc/auth/auth_bloc.dart';
import 'package:fusecash/worldxr/src/bloc/unity/unity_bloc.dart';
import 'package:fusecash/worldxr/src/bloc/wallet/wallet_bloc.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/draggable_item.dart';
import 'package:fusecash/worldxr/src/data/models/privateKey_model.dart';
import 'package:fusecash/worldxr/src/data/user.dart';
import 'package:fusecash/worldxr/src/locator.dart';
import 'package:fusecash/worldxr/src/services/unity_service.dart';
import 'package:fusecash/worldxr/src/ui/login_page.dart';
import 'package:fusecash/worldxr/src/ui/style.dart';
import 'package:fusecash/worldxr/src/ui/widgets/dialogs.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UnityWidgetController _unityWidgetController;
  double posx = 100.0;
  double posy = 100.0;
  UnityObjectType objectSelected = UnityObjectType.none;
  UnityBloc _unityBloc;
  UnityService _unityService = locator.get();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _unityBloc = Provider.of<UnityBloc>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    PrivateKeyModel _privateKeyModel = Provider.of<PrivateKeyModel>(context);
    UserModel _userModel = Provider.of<UserModel>(context);
    // ignore: close_sinks
    WalletBloc walletBloc = BlocProvider.of<WalletBloc>(context);
    return Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoadingState) {
                setState(() {
                  _loading = true;
                });
                return;
              }
              if (state is SignedInWithoutKeyState) {
                _userModel.updateUser(state.user);
              }

              if (state is SignedInState) {
                _privateKeyModel.setPrivateKey(state.privateKey);
                _userModel.updateUser(state.user);
                walletBloc.setWalletInfo(
                    state.walletObjectState.address,
                    state.walletObjectState.ethBalance,
                    state.walletObjectState.holdings);
              }

              if (state is SignedOutState) {
                _privateKeyModel.setPrivateKey(null);
                _userModel.updateUser(null);
              }

              if (state is SignedUpState) {
                _privateKeyModel.setPrivateKey(state.privateKey);
                _userModel.updateUser(state.user);
                walletBloc.setWalletInfo(
                    state.walletObjectState.address,
                    state.walletObjectState.ethBalance,
                    state.walletObjectState.holdings);
              }
              setState(() {
                _loading = false;
              });
            },
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.blue_grey),
                    ),
                  )
                : _privateKeyModel.privateKey != null
                    ? _homeContent(_userModel.user)
                    : LoginPage()));
  }

  Widget _homeContent(User user) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: UnityWidget(
                  onUnityViewCreated: onUnityCreated,
                  onUnityMessage: onUnityMessage),
            ),
            Expanded(
              child: Container(
                height: 100,
                child: ListView.builder(
                  itemCount: xrDraggableItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await selectObject(
                            xrDraggableItems[index].unityObjectType);
                        /*  _unityBloc.add(SaveUnityObject(user.id,
                            Random().nextInt(1000).toString(), 78.6, 78.6)); */
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2,
                              color: objectSelected ==
                                      xrDraggableItems[index].unityObjectType
                                  ? Colors.amberAccent
                                  : Colors.transparent),
                          color: AppColors.blue_transparent,
                        ),
                        child: Column(
                          children: <Widget>[
                            xrDraggableItems[index].image,
                            Text(xrDraggableItems[index].title)
                          ],
                        ),
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
            )
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: FloatingActionButton(
              backgroundColor: AppColors.blue_grey,
              child: Icon(Icons.account_balance_wallet_sharp),
              onPressed: () {
                showWallet(context, user);
              }),
        ),
      ],
    );
  }

  void onUnityCreated(controller) {
    this._unityWidgetController = controller;
  }

  // Communication from Unity to Flutter
/*   {
type: "MESSAGE_TYPE",
content: Content Object
} */
  void onUnityMessage(controller, message) {
    print('Received message from unity: ${message.toString()}');
    Map<String, dynamic> data = message['data'];
    switch (message['type']) {
      case "NEW_OBJECT":
        _unityBloc.add(SaveUnityObject(
            data['id'],
            data['content'],
            data['location']['latitude'],
            data['location']['longitude'],
            data['location']['altitude']));
        break;

      case "CURRENT_LOCATION":
        _unityBloc.add(LocationFromUnity(data['latitude'], data['longitude']));
        break;

      case "REQUEST_OBJECT":
        _unityBloc.add(RetrieveObject(data['id']));
        break;
      case "UNITY_ERROR":
        print(data['message']);
        break;
    }
  }

  selectObject(UnityObjectType object) async {
    String objectType = getObjectType(object);
    if (object == objectSelected)
      setState(() {
        objectSelected = UnityObjectType.none;
      });
    else {
      setState(() {
        objectSelected = object;
      });
    }
    print("sending message to select object in Unity with type: " + objectType);
    _unityService.selectObjectInUnity(_unityWidgetController, objectType);
  }

  getObjectType(UnityObjectType object) {
    switch (object) {
      case UnityObjectType.zombie:
        return "zombie";
        break;
      case UnityObjectType.box:
        return "box";
        break;
      case UnityObjectType.text:
        return "text";
        break;
      case UnityObjectType.image:
        return "image";
        break;
      case UnityObjectType.none:
        return "none";
        break;
    }
  }
}
