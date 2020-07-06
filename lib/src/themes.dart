import 'package:flutter/material.dart';

class Themes {
  static const DARK_THEME_CODE = 0;

  static final _dark = ThemeData.dark();

  static ThemeData getTheme() {
    return _dark;
  }
}
