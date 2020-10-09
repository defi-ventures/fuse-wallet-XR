import 'dart:convert';

import 'package:fusecash/worldxr/src/bloc/auth/auth_bloc.dart';
import 'package:fusecash/worldxr/src/bloc/unity/unity_bloc.dart';
import 'package:fusecash/worldxr/src/data/user.dart';
import 'package:fusecash/worldxr/src/locator.dart';
import 'package:fusecash/worldxr/src/services/unity_service.dart';
import 'package:fusecash/worldxr/src/ui/login_page.dart';
import 'package:fusecash/worldxr/src/ui/widgets/dialogs.dart';
import 'package:crossplat_objectid/crossplat_objectid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:fusecash/worldxr/src/ui/style.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/draggable_item.dart';

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

  @override
  void initState() {
    super.initState();
    _unityBloc = BlocProvider.of<UnityBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, AuthState state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return _homeContent(state.user);
            break;
          case AuthStatus.unauthenticated:
            return LoginPage();
            break;
          case AuthStatus.unknown:
            return LoginPage();
            break;
          case AuthStatus.loading:
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.blue_grey),
                ),
              ),
            );
            break;
          default:
            return LoginPage();
        }
      },
    );
  }

  Widget _homeContent(User user) {
    return BlocConsumer(
      cubit: _unityBloc,
      listener: (context, UnityState state) {
        if (state.unityStatus == UnityStatus.locationRetrieved) {
          _unityBloc.add(LoadObjectsForLocation(state.userLocation));
        }
      },
      builder: (BuildContext context, UnityState state) {
        return Scaffold(
          body: Stack(
            children: [
              UnityWidget(
                  onUnityViewCreated: onUnityCreated,
                  onUnityMessage: onUnityMessage),
              Positioned(
                bottom: 5,
                left: 0,
                child: Container(
                  color: Colors.transparent,
                  height: 130,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemExtent: 80,
                    itemCount: xrItems.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          await selectObject(xrItems[index].unityObjectType);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: objectSelected ==
                                        xrItems[index].unityObjectType
                                    ? 3
                                    : 1,
                                color: objectSelected ==
                                        xrItems[index].unityObjectType
                                    ? AppColors.blue_grey
                                    : Colors.white),
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: xrItems[index].image,
                          ),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                ),
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
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(label: "Wallet", icon: Container()),
              BottomNavigationBarItem(label: "Map", icon: Container())
            ],
          ),
        );
      },
    );
  }

  void onUnityCreated(controller) {
    this._unityWidgetController = controller;
  }

  // Communication from Unity to Flutter
/*   {
type: "MESSAGE_TYPE",
data: Content Object
} */
  void onUnityMessage(controller, message) {
    final user = context.bloc<AuthBloc>().state.user;
    message = jsonDecode(message);
    print('Received message from unity: ${message.toString()}');
    Map<String, dynamic> data = message['data'];
    switch (message['name']) {
      case "NEW_OBJECT":
        _unityBloc.add(SaveUnityObject(
            ObjectId().toHexString(),
            user.id,
            data['lat'],
            data['lng'],
            data['alt'],
            data['rotX'],
            data['rotY'],
            data['rotZ']));
        break;

      case "CURRENT_LOCATION":
        _unityBloc.add(LocationFromUnity(
            data['Latitude'], data['Longitude'], data["Altitude"]));
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
