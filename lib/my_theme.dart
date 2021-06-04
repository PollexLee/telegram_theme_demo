import 'package:flutter/material.dart';
import 'package:telegram_theme_demo/tg_theme_widget.dart';

class MyThemeModel extends ChangeNotifier {
  MyThemeModel(this.controller) {
    _customTheme = _lightTheme;
  }
  TgThemeController controller;
  ThemeMode _themeMode = ThemeMode.light;

  CustomTheme _customTheme;

  CustomTheme _lightTheme = CustomTheme();
  DarkTheme _darkTheme = DarkTheme();
  // ThemeData _themeData;

  ThemeMode get themeMode => _themeMode;

  CustomTheme get customTheme => _customTheme;

  void switchTheme({Offset offset}) async {
    await controller.capture(offset: offset);
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _customTheme = _darkTheme;
    } else {
      _themeMode = ThemeMode.light;
      _customTheme = _lightTheme;
    }
    notifyListeners();
    controller.startAnim();
  }

  bool get isLight => _themeMode == ThemeMode.light;
}

class CustomTheme {
  Color get titleColor => Colors.black87;

  Color get iconColor => Colors.black45;

  Color get backgroundColor => const Color(0xFFF9F9FB);
}

class DarkTheme extends CustomTheme {
  @override
  Color get titleColor => Colors.white70;

  @override
  Color get iconColor => Colors.white60;

  @override
  Color get backgroundColor => const Color(0xFF181818);
}
