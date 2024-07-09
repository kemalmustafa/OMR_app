import 'package:flutter/material.dart';

const colorBlueGrey = Color(0xFF2E4058);
const colorBlack = Color.fromRGBO(48, 47, 48, 1.0);
const colorGrey = Color.fromRGBO(141, 141, 141, 1.0);
const colorWhite = Colors.white;

const imageSplashScreen = 'assets/splash_art.jpeg';


const mainPageIconSize = 50.0;
const mainPageIconColor = colorBlueGrey;
const mainPageIconTextSize = 15.0;
const mainPageIconTextStyle = TextStyle(
  color: colorBlueGrey,
  fontSize: mainPageIconTextSize,
  fontWeight: FontWeight.bold,
);
const mainPageIconPadding = EdgeInsets.symmetric(vertical: 30);

const serverUrl = "http://165.22.83.114:5000/";
const mainPageExamEditorIcon = Icon(Icons.create);
const mainPageExamListIcon = Icon(Icons.list);
const mainPageSupportedOpticsIcon = Icon(Icons.info);
const mainPageInstructionsIcon = Icon(Icons.help);