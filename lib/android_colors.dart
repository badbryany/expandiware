import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.app/colors');

Future<MaterialYouPalette?> getMaterialYouColor() async {
  // Material You colors are available on Android only
  if (defaultTargetPlatform != TargetPlatform.android) return null;

  try {
    final data = await platform.invokeMethod('getMaterialYouColors');
    if (data == null) return null;

    final Map<String, dynamic> items = (json.decode(data) as Map<String, dynamic>);
    return MaterialYouPalette(
      accent1: items.getAccent1(),
      accent2: items.getAccent2(),
      accent3: items.getAccent3(),
      neutral1: items.getNeutral1(),
      neutral2: items.getNeutral2(),
    );
  } on PlatformException catch (_) {
    return null;
  }
}

class MaterialYouPalette {
  final MaterialColor accent1;
  final MaterialColor accent2;
  final MaterialColor accent3;
  final MaterialColor neutral1;
  final MaterialColor neutral2;

  MaterialYouPalette({
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.neutral1,
    required this.neutral2,
  });
}

int _parseHexString(String value) => int.parse(value.substring(3, 9), radix: 16) + 0xFF000000;

extension _ColorExtractionExtension on Map<String, dynamic> {
  Color getColor(String colorName) {
    final value = this[colorName];
    final parsed = _parseHexString(value);
    return Color(parsed);
  }

  MaterialColor getAccent1() {
    return MaterialColor(
      _parseHexString(this['system_accent1_100']),
      <int, Color>{
        50: getColor('system_accent1_50'),
        100: getColor('system_accent1_100'),
        200: getColor('system_accent1_200'),
        300: getColor('system_accent1_300'),
        400: getColor('system_accent1_400'),
        500: getColor('system_accent1_500'),
        600: getColor('system_accent1_600'),
        700: getColor('system_accent1_700'),
        800: getColor('system_accent1_800'),
        900: getColor('system_accent1_900'),
      },
    );
  }

  MaterialColor getAccent2() {
    return MaterialColor(
      _parseHexString(this['system_accent2_100']),
      <int, Color>{
        50: getColor('system_accent2_50'),
        100: getColor('system_accent2_100'),
        200: getColor('system_accent2_200'),
        300: getColor('system_accent2_300'),
        400: getColor('system_accent2_400'),
        500: getColor('system_accent2_500'),
        600: getColor('system_accent2_600'),
        700: getColor('system_accent2_700'),
        800: getColor('system_accent2_800'),
        900: getColor('system_accent2_900'),
      },
    );
  }

  MaterialColor getAccent3() {
    return MaterialColor(
      _parseHexString(this['system_accent3_100']),
      <int, Color>{
        50: getColor('system_accent3_50'),
        100: getColor('system_accent3_100'),
        200: getColor('system_accent3_200'),
        300: getColor('system_accent3_300'),
        400: getColor('system_accent3_400'),
        500: getColor('system_accent3_500'),
        600: getColor('system_accent3_600'),
        700: getColor('system_accent3_700'),
        800: getColor('system_accent3_800'),
        900: getColor('system_accent3_900'),
      },
    );
  }

  MaterialColor getNeutral1() {
    return MaterialColor(
      _parseHexString(this['system_neutral1_100']),
      <int, Color>{
        50: getColor('system_neutral1_50'),
        100: getColor('system_neutral1_100'),
        200: getColor('system_neutral1_200'),
        300: getColor('system_neutral1_300'),
        400: getColor('system_neutral1_400'),
        500: getColor('system_neutral1_500'),
        600: getColor('system_neutral1_600'),
        700: getColor('system_neutral1_700'),
        800: getColor('system_neutral1_800'),
        900: getColor('system_neutral1_900'),
      },
    );
  }

  MaterialColor getNeutral2() {
    return MaterialColor(
      _parseHexString(this['system_neutral2_100']),
      <int, Color>{
        50: getColor('system_neutral2_50'),
        100: getColor('system_neutral2_100'),
        200: getColor('system_neutral2_200'),
        300: getColor('system_neutral2_300'),
        400: getColor('system_neutral2_400'),
        500: getColor('system_neutral2_500'),
        600: getColor('system_neutral2_600'),
        700: getColor('system_neutral2_700'),
        800: getColor('system_neutral2_800'),
        900: getColor('system_neutral2_900'),
      },
    );
  }
}