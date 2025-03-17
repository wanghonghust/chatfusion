import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/dialog.dart';
import 'package:chatfusion/notifier/theme.dart';
import 'package:chatfusion/routes.dart';
import 'package:chatfusion/shell/nav_bar.dart';
import 'package:chatfusion/shell/shell.dart';
import 'package:chatfusion/tree.dart';
import 'package:chatfusion/window.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as fa;
import 'package:chatfusion/sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    await fa.Window.initialize();
    fa.Window.enableShadow();
  }

  if (Platform.isWindows) {
    await fa.Window.hideWindowControls();
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) {
      ThemeNotifier notifier =
          ThemeNotifier(lightTheme, context, ThemeMode.system);
      return notifier;
    }),
  ], child: ChatfusionApp()));
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = Size(400, 360)
        ..size = Size(1000, 540)
        ..alignment = Alignment.center
        ..show();
    });
  }
}

class ChatfusionApp extends StatefulWidget {
  const ChatfusionApp({super.key});

  @override
  State<ChatfusionApp> createState() => _ChatfusionAppState();
}

class _ChatfusionAppState extends State<ChatfusionApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, themeNotifier, child) {
      return ShadcnApp(
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.currentTheme,
        darkTheme: darkTheme,
        themeMode: themeNotifier.themeMode,
        home: AppShell(body: TreePage()),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Alert(
      title: Text('Alert title'),
      content: Text('This is alert content.'),
      leading: Icon(Icons.info_outline),
    );
  }
}

class MenuPage extends StatefulWidget {
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool expanded = false;
  int selected = 0;

  NavigationItem buildButton(String text, IconData icon) {
    return NavigationItem(
      label: Text(text),
      alignment: Alignment.centerLeft,
      child: Icon(icon),
      selectedStyle: ButtonStyle.primaryIcon(),
    );
  }

  NavigationLabel buildLabel(String label) {
    return NavigationLabel(
      alignment: Alignment.centerLeft,
      child: Text(label).semiBold().muted(),
      // padding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedContainer(
      height: 600,
      width: 800,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            backgroundColor: theme.colorScheme.card,
            labelType: NavigationLabelType.expanded,
            labelPosition: NavigationLabelPosition.end,
            alignment: NavigationRailAlignment.start,
            expanded: expanded,
            index: selected,
            onSelected: (value) {
              setState(() {
                selected = value;
              });
            },
            children: [
              NavigationButton(
                child: Icon(Icons.menu),
                alignment: Alignment.centerLeft,
                label: Text('Menu'),
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
              ),
              NavigationDivider(),
              buildLabel('You'),
              buildButton('Home', Icons.home_filled),
              buildButton('Trending', Icons.trending_up),
              buildButton('Subscription', Icons.subscriptions),
              NavigationDivider(),
              buildLabel('History'),
              buildButton('History', Icons.history),
              buildButton('Watch Later', Icons.access_time_rounded),
              NavigationDivider(),
              buildLabel('Movie'),
              buildButton('Action', Icons.movie_creation_outlined),
              buildButton('Horror', Icons.movie_creation_outlined),
              buildButton('Thriller', Icons.movie_creation_outlined),
              NavigationDivider(),
              buildLabel('Short Films'),
              buildButton('Action', Icons.movie_creation_outlined),
              buildButton('Horror', Icons.movie_creation_outlined),
            ],
          ),
          const VerticalDivider(),
          const Flexible(child: SizedBox()),
        ],
      ),
    );
  }
}
