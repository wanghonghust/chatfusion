import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/database/index.dart';
import 'package:chatfusion/notifier/settings.dart';
import 'package:chatfusion/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as fa;
import 'package:provider/provider.dart' as p;

Future<void> main() async {
  await initDatabase();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    await fa.Window.initialize();
    fa.Window.enableShadow();
  }

  if (Platform.isWindows) {
    await fa.Window.hideWindowControls();
  }
  await dotenv.load(fileName: ".env");
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('zh', 'CN')],
      path: 'assets/translations',
      fallbackLocale: Locale('zh', 'CN'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            SettingsNotifier notifier = SettingsNotifier(
              lightTheme,
              context,
              ThemeMode.system,
              Locale('zh', 'CN'),
            );
            return notifier;
          }),
        ],
        child: ChatfusionApp(),
      ),
    ),
  );
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = Size(250, 360)
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
  late GoRouter router;
  @override
  void initState() {
    super.initState();
    router = GoRouter(routes: routes, initialLocation: '/');
  }

  @override
  Widget build(BuildContext context) {
    return p.Consumer<SettingsNotifier>(
        builder: (context, settingsNotifier, child) {
      return ShadcnApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: settingsNotifier.currentTheme,
        darkTheme: darkTheme,
        themeMode: settingsNotifier.themeMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: settingsNotifier.language,
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
