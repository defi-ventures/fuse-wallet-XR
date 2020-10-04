import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  User user;

  updateUser(User user) {
    this.user = user;
    notifyListeners();
  }
}

class User {
  String id;
  DateTime date;
  DateTime updateDate;
  String name;
  String email;
  String walletAddress;
  bool termsAgreed;
  String locale;
  String verifierId;
  String imageUrl;

  // only temp stored when doing sign up

  User({this.id, this.name, this.email, this.imageUrl});

  User.fromData(Map<String, dynamic> data) {
    id = data['_id'];
    name = data['name'];
    walletAddress = data['walletAddress'];
    date = data['date'];
    updateDate = data['updatedAt'];
    locale = data['locale'];
    verifierId = data['verifierId'];
    email = data['email'];
    imageUrl = data['imageUrl'];
  }

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['email'] = email;
    m['imageUrl'] = imageUrl;

    return m;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      "name": this.name,
      'verifierId': verifierId,
      'locale': locale,
      'walletAddress': this.walletAddress,
      "email": this.email,
      "date": this.date,
      "updateDate": this.updateDate,
    };
  }
}
