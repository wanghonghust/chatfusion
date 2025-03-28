import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/notifier/theme.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  ThemeNotifier? themeNotifier;
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
    themeNotifier = Provider.of<ThemeNotifier>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final buttonColors = WindowButtonColors(
      iconNormal: themeNotifier!.isDarkMode ? Colors.white : Colors.black,
      iconMouseDown: themeNotifier!.isDarkMode ? Colors.white : Colors.black,
      iconMouseOver: themeNotifier!.isDarkMode ? Colors.white : Colors.black,
      normal: Colors.transparent,
      mouseOver: themeNotifier!.isDarkMode
          ? Colors.white.withAlpha(20)
          : Colors.black.withAlpha(20),
      mouseDown: themeNotifier!.isDarkMode
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
          icon: const Icon(RadixIcons.minus),
        ),
        appWindow.isMaximized
            ? IconButton.ghost(
                onPressed: maximizeOrRestore,
                density: ButtonDensity.icon,
                icon: const Icon(RadixIcons.exitFullScreen),
              )
            : IconButton.ghost(
                onPressed: maximizeOrRestore,
                density: ButtonDensity.icon,
                icon: const Icon(RadixIcons.enterFullScreen)),
        IconButton.ghost(
            onPressed: close,
            density: ButtonDensity.icon,
            icon: const Icon(RadixIcons.cross2)),
      ],
    );
  }
}
