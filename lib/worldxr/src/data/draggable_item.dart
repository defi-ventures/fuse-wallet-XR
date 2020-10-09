import 'package:flutter/material.dart';

class XRItem {
  String title;
  UnityObjectType unityObjectType;
  Widget image;

  XRItem(this.title, this.unityObjectType, this.image);
}

enum UnityObjectType { zombie, box, text, image, none }
