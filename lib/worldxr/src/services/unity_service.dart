import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/unity_object.dart';

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
  Future<int> addObjectToMongo(UnityObject object, String fileName) async {
    try {
      Response response = await Dio().post("$serverIp/api/object", data: {
        "s3_address": fileName,
        "user": object.userID,
        "location": {"type": "Point", "coordinates": object.location}
      });
      print(response.data);
      return response.statusCode;
    } catch (e) {
      print(e);
      return null;
    }
  }

//add object to S3
  Future<String> addObjectToS3(UnityObject object) async {
    try {
      Response response = await Dio().post("$serverIp/api/object/s3", data: {
        "fileName": object.id + '.json',
        "user_id": object.userID,
        "content": object.content,
      });

      return response.data;
    } catch (e) {
      print(e);
      return null;
    }
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
