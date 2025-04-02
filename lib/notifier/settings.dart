import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_acrylic/window.dart' as faw;
import 'package:flutter_acrylic/window_effect.dart';

class SettingsNotifier with ChangeNotifier {
  ThemeData _currentTheme;
  BuildContext context;
  ThemeMode _themeMode;
  WindowEffect _effect = WindowEffect.mica;
  Locale _language = Locale('zh', 'CN');

  SettingsNotifier(
    this._currentTheme,
    this.context,
    this._themeMode,
    this._language,
  );

  ThemeData get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  WindowEffect get effect => _effect;
  bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  Locale get language => _language;

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

  bool setLanguage(Locale language) {
    _language = language;
    context.setLocale(language);
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
