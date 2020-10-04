
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fusecash/worldxr/src/constants.dart';
import 'package:fusecash/worldxr/src/data/user.dart';
import 'package:json_store/json_store.dart';

class AuthService extends ChangeNotifier {
  final _secureStorage = FlutterSecureStorage();
  final JsonStore _jsonStore = JsonStore();

  Future<String> logInWithVerifier(String email) async {
    try {
      Response response = await Dio().post("$serverIp", data: {"email": email});
      if (response.statusCode == 200) return response.data;
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> signUpWithVerifier(String email) async {
    try {
      Response response =
          await Dio().post("$serverIp/api/user", data: {"email": email});
      print(response.data);
      return response.statusCode;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      Response response = await Dio().post("$serverIp/api/apk/userlogin",
          data: {"email": email, 'password': password});
      print(response.data);
      return User(id: response.data['id'], email: response.data['email']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> signUpWithEmailPassword(String email, String password) async {
    try {
      Response response = await Dio().post("$serverIp/api/apk/user",
          data: {"email": email, 'password': password});
      print(response.data);
      return response.statusCode;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User> getUserWithEmail(String email) async {
    try {
      Response response = await Dio().get("$serverIp/api/user/:$email");
      print(response.data);
      return User(email: response.data['email']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> storeUser(User user) async {
    return await _jsonStore.setItem('user', user.toJSONEncodable());
  }

  Future<User> getUser() async {
    Map<String, dynamic> userJson = await _jsonStore.getItem('user');
    return User.fromData(userJson);
  }

  Future<void> clearStoredData() async {
    await _jsonStore.deleteItem('user');
    return await this.deletePrivateKey();
  }

  Future<void> storePrivateKey(String key) async {
    return await _secureStorage.write(key: "privateKey", value: key);
  }

  Future<String> readPrivateKey() async {
    return await _secureStorage.read(key: "privateKey");
  }

  Future<void> deletePrivateKey() async {
    return await _secureStorage.delete(key: "privateKey");
  }
}
