import 'package:flutter/material.dart';
import 'package:fusecash/worldxr/src/data/draggable_item.dart';

List<DraggableItem> xrDraggableItems = [
  DraggableItem("zombie", UnityObjectType.zombie,
      Image.asset("assets/images/zombie.png")),
  DraggableItem(
      "box", UnityObjectType.box, Image.asset("assets/images/zombie.png")),
];

const String serverIp = "https://worldxrapi.tokenizer.cc";

enum Verifier { google, facebook, apple }
