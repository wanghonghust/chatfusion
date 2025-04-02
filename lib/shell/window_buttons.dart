import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/notifier/settings.dart';
import 'package:chatfusion/widgets/svg_icon.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  SettingsNotifier? settingsNotifier;
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  void minimize() {
    setState(() {
      appWindow.minimize();
    });
  }

  void close() {
    setState(() {
      appWindow.close();
    });
  }

  @override
  void didChangeDependencies() {
    settingsNotifier = Provider.of<SettingsNotifier>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final buttonColors = WindowButtonColors(
      iconNormal: settingsNotifier!.isDarkMode ? Colors.white : Colors.black,
      iconMouseDown: settingsNotifier!.isDarkMode ? Colors.white : Colors.black,
      iconMouseOver: settingsNotifier!.isDarkMode ? Colors.white : Colors.black,
      normal: Colors.transparent,
      mouseOver: settingsNotifier!.isDarkMode
          ? Colors.white.withAlpha(20)
          : Colors.black.withAlpha(20),
      mouseDown: settingsNotifier!.isDarkMode
          ? Colors.white.withAlpha(40)
          : Colors.black.withAlpha(40),
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseDown:
          brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseOver:
          brightness == Brightness.light ? Colors.black : Colors.white,
      normal: Colors.transparent,
      mouseOver: brightness == Brightness.light ? Colors.red : Colors.red,
      mouseDown: brightness == Brightness.light ? Colors.red : Colors.red,
    );
    return Row(
      children: [
        IconButton.ghost(
          onPressed: minimize,
          density: ButtonDensity.icon,
          icon: SvgIcon(
                  'assets/svg/minimize.svg',
                  size: 18,
                ),
        ),
        appWindow.isMaximized
            ? IconButton.ghost(
                onPressed: maximizeOrRestore,
                density: ButtonDensity.icon,
                icon: SvgIcon(
                  'assets/svg/unmaximize.svg',
                  size: 18,
                ),
              )
            : IconButton.ghost(
                onPressed: maximizeOrRestore,
                density: ButtonDensity.icon,
                icon: SvgIcon(
                  'assets/svg/maximize.svg',
                  size: 18,
                ),
              ),
        IconButton.ghost(
            onPressed: close,
            density: ButtonDensity.icon,
            icon: SvgIcon(
                  'assets/svg/close.svg',
                  size: 18,
                ),),
      ],
    );
  }
}
