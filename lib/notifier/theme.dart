import 'dart:io';
import 'dart:ui';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_acrylic/window.dart' as faw;
import 'package:flutter_acrylic/window_effect.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme;
  BuildContext context;
  ThemeMode _themeMode;
  WindowEffect _effect = WindowEffect.mica;

  ThemeNotifier(this._currentTheme, this.context, this._themeMode);

  ThemeData get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  WindowEffect get effect => _effect;
  bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  void init() {
    faw.Window.setEffect(
      effect: _effect,
      dark: isDarkMode,
    );
  }

  void setEffect(WindowEffect effect) {
    _effect = effect;
    faw.Window.setEffect(
      effect: _effect,
      dark: isDarkMode,
    );
    notifyListeners();
  }

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    faw.Window.setEffect(
      effect: _effect,
      dark: isDarkMode,
    );
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system &&
        MediaQuery.of(context).platformBrightness == Brightness.dark) {
      return true;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool setColorScheme(ColorScheme colorScheme) {
    _currentTheme = _currentTheme.copyWith(colorScheme: colorScheme);
    notifyListeners();
    return true;
  }
}

var lightTheme = ThemeData(
  colorScheme: ColorSchemes.lightGreen(),
  radius: 0.5,
);

var darkTheme = ThemeData(
  colorScheme: ColorSchemes.darkRose(),
  radius: 0.5,
);

