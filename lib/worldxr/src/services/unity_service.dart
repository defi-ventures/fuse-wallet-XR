import 'dart:convert';

import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/unity_object.dart';
import 'package:dio/dio.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityService {
  // saving unity data to backend

  // find user’s objects/assets
  Future<List<UnityObject>> getUsersObjects(String id) async {
    try {
      List<UnityObject> objects = [];
      Response response = await Dio().get("$serverIp/api/object/:$id");
      print(response.data);
      List<dynamic> objectJsons = response.data;
      objectJsons.forEach((objectJson) {
        objects.add(UnityObject.fromData(objectJson));
      });

      return objects;
    } catch (e) {
      print(e);
      return null;
    }
  }

//add object to mongoDB
  Future<int> addObjectToMongo(UnityObject object) async {
    try {
      Response response = await Dio().post("$serverIp/api/object", data: {
        "id": object.id,
        "user": object.userID ?? '5f7f2582fbfc4a971970eee1',
        "location": {
          "type": "Point",
          "coordinates": [
            object.location['lng'],
            object.location['lat'],
          ]
        },
        "rotX": object.rotX,
        "rotY": object.rotY,
        "rotZ": object.rotZ,
      });
      print(response.data);
      return response.statusCode;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<UnityObject>> getObjectsForLocation(
      String lat, String lng) async {
    // String locationHex = [lat,lng].toString().to
    try {
      Response response = await Dio().post(
        "$serverIp/api/object/location/5b2e20202034332e37373933393237202c2020202d37392e34313438333020205d",
      );

      print(response.data);
    } catch (e) {}
  }

  // Sending messages to Unity from Flutter

  // select object
  selectObjectInUnity(
      UnityWidgetController unityWidgetController, String objectType) {
    String jsonString = json.encode({
      'name': "OBJECT_SELECTED",
      'data': {'type': objectType}
    });
    unityWidgetController.postMessage(
      'AR Session Origin',
      'ReceiveMessage',
      jsonString,
    );
    print("select object message sent to unity");
  }

  // place object
  placeObjectInUnity(UnityWidgetController unityWidgetController) {
    print("Placing object in unity");
    String jsonString = json.encode({'name': "PlaceObject"});
    unityWidgetController.postMessage(
      'AR Session Origin',
      'ReceiveMessage',
      jsonString,
    );
  }
}
