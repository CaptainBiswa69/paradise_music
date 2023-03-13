import 'package:flutter/material.dart';

MaterialColor PrimaryMaterialColor = MaterialColor(
  4278518790,
  <int, Color>{
    50: Color.fromRGBO(
      5,
      4,
      6,
      .1,
    ),
    100: Color.fromRGBO(
      5,
      4,
      6,
      .2,
    ),
    200: Color.fromRGBO(
      5,
      4,
      6,
      .3,
    ),
    300: Color.fromRGBO(
      5,
      4,
      6,
      .4,
    ),
    400: Color.fromRGBO(
      5,
      4,
      6,
      .5,
    ),
    500: Color.fromRGBO(
      5,
      4,
      6,
      .6,
    ),
    600: Color.fromRGBO(
      5,
      4,
      6,
      .7,
    ),
    700: Color.fromRGBO(
      5,
      4,
      6,
      .8,
    ),
    800: Color.fromRGBO(
      5,
      4,
      6,
      .9,
    ),
    900: Color.fromRGBO(
      5,
      4,
      6,
      1,
    ),
  },
);

ThemeData myTheme = ThemeData(
  fontFamily: "customFont",
  primaryColor: Color(0xff050406),
  primarySwatch: PrimaryMaterialColor,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Color(0xff050406),
      ),
    ),
  ),
);
