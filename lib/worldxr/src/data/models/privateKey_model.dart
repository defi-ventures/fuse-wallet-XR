import 'package:flutter/material.dart';

class PrivateKeyModel extends ChangeNotifier {
  String _privateKey;

  get privateKey => _privateKey;

  setPrivateKey(key) {
    _privateKey = key;
    notifyListeners();
  }
}
