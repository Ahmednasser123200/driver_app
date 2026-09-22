import 'package:flutter/material.dart';

abstract final class AppColors {
  static const MaterialColor primary = MaterialColor(
    0xFFD21E6A,
    <int, Color>{
      50: Color(0xFFFDF1F6),
      100: Color(0xFFF9D6E4),
      200: Color(0xFFF3ACCA),
      300: Color(0xFFED82B0),
      400: Color(0xFFE85796),
      500: Color(0xFFD21E6A),
      600: Color(0xFFC91963),
      700: Color(0xFF952755),
      800: Color(0xFF791F45),
      900: Color(0xFF522032),
    },
  );

  static const Color secondary = Color(0xFFFFB655);

  static const Color black = Color(0xFF0C1015);
  static const Color white = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F4F4);
  static const Color surfaceLowest = Color(0xFFFEF7FF);

  static const MaterialColor grey = MaterialColor(
    0xFF535353,
    <int, Color>{
      50: Color(0xFFF6F6F6),
      100: Color(0xFFEFEFEF),
      200: Color(0xFFD8D8D8),
      300: Color(0xFFC4C4C4),
      400: Color(0xFFA6A6A6),
      500: Color(0xFF535353),
      600: Color(0xFF49454F),
      700: Color(0xFF3D3A43),
      800: Color(0xFF2E2B33),
      900: Color(0xFF1F1D23),
    },
  );

  static const Color border = Color(0xFFCFCFCF);
  static const Color divider = Color(0xFFEDEDED);

  static const MaterialColor error = MaterialColor(
    0xFFB3261E,
    <int, Color>{
      50: Color(0xFFFBEBEA),
      100: Color(0xFFF5C6C3),
      200: Color(0xFFEE9A96),
      300: Color(0xFFE26E68),
      400: Color(0xFFD84B44),
      500: Color(0xFFB3261E),
      600: Color(0xFFCC1010),
      700: Color(0xFF8F1D17),
      800: Color(0xFF711712),
      900: Color(0xFF52110D),
    },
  );

  static const MaterialColor success = MaterialColor(
    0xFF0CB359,
    <int, Color>{
      50: Color(0xFFD1FBD3),
      100: Color(0xFFA9F6B0),
      200: Color(0xFF7CED89),
      300: Color(0xFF4FE264),
      400: Color(0xFF2FD75C),
      500: Color(0xFF0CB359),
      600: Color(0xFF0A9B4C),
      700: Color(0xFF097F3E),
      800: Color(0xFF076632),
      900: Color(0xFF054823),
    },
  );

  static const MaterialColor pending = MaterialColor(
    0xFFC8D444,
    <int, Color>{
      50: Color(0xFFF8F9E8),
      100: Color(0xFFECEFBC),
      200: Color(0xFFDFE48F),
      300: Color(0xFFD4DA66),
      400: Color(0xFFC8D444),
      500: Color(0xFFA9B62E),
      600: Color(0xFF899424),
      700: Color(0xFF6C741B),
      800: Color(0xFF4F5513),
      900: Color(0xFF35390C),
    },
  );

  static const MaterialColor coral = MaterialColor(
    0xFFFD697F,
    <int, Color>{
      50: Color(0xFFFFF0F2),
      100: Color(0xFFFED8DD),
      200: Color(0xFFFEB4BD),
      300: Color(0xFFFD8F9F),
      400: Color(0xFFFD7D8E),
      500: Color(0xFFFD697F),
      600: Color(0xFFE1546D),
      700: Color(0xFFB84359),
      800: Color(0xFF8F3345),
      900: Color(0xFF682432),
    },
  );

  static const Color amber = Color(0xFFFFB655);
  static const Color yellow = Color(0xFFFFDA44);

  static const Color shadow = Color(0x1A0C1015);
  static const Color transparent = Color(0x00000000);
}