import 'package:fusecash/worldxr/src/data/draggable_item.dart';
import 'package:flutter/material.dart';

List<XRItem> xrItems = [
  XRItem(
      "zombie",
      UnityObjectType.zombie,
      Image.asset(
        "assets/images/zombie.png",
        fit: BoxFit.contain,
      )),
  XRItem(
      "box",
      UnityObjectType.box,
      Image.asset(
        "assets/images/zombie.png",
        fit: BoxFit.contain,
      )),
];

const String serverIp = "https://worldxrapi.tokenizer.cc";

enum Verifier { google, facebook, apple }

extension VerifierExtension on Verifier {}
