import 'package:flutter/material.dart';

class DraggableItem {
  String title;
  UnityObjectType unityObjectType;
  Widget image;

  DraggableItem(this.title, this.unityObjectType, this.image);
}

enum UnityObjectType { zombie, box, text, image, none }
