import 'package:flutter/material.dart';
import 'package:my_camera/constants/colors.dart';

ThemeData mainTheme = ThemeData(
  primarySwatch: createMaterialColor(darkBlueColor),
);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      darkBlueColor,
      lightBlueColor
    ]
);

LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      lightBlueButtonColor,
      darkBlueButtonColor
    ]
);

TextStyle detailsTextStyle = TextStyle(
  color: whiteColor,
  fontSize: 18,
  fontWeight: FontWeight.w400
);