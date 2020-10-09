import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  User user;

  updateUser(User user) {
    this.user = user;
    notifyListeners();
  }
}

class User {
  final String id;
  final DateTime date;
  final DateTime updateDate;
  final String name;
  final String email;
  final String walletAddress;
  final bool termsAgreed;
  final String locale;
  final String verifierId;
  final String imageUrl;

  // only temp stored when doing sign up

  const User({
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    this.date,
    this.updateDate,
    this.walletAddress,
    this.termsAgreed,
    this.locale,
    this.verifierId,
  });

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

  /// Empty user which represents an unauthenticated user.
  static const empty = const User(email: '', id: '', name: null);
}
