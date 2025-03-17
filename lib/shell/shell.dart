import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/notifier/theme.dart';
import 'package:chatfusion/routes.dart';
import 'package:chatfusion/shell/nav_bar.dart';
import 'package:chatfusion/shell/screen_size.dart';
import 'package:chatfusion/shell/window_buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  final Widget body;
  const AppShell({
    super.key,
    required this.body,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ThemeNotifier? themeNotifier;
  bool expanded = false;
  late GoRouter router;
  @override
  void initState() {
    super.initState();
    router = GoRouter(routes: routes, initialLocation: '/');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    themeNotifier!.init();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = getScreenSize(context);
    return DrawerOverlay(
        child: Column(
      children: [
        TitleBar(
          leading: NavigationButton(
            alignment: Alignment.centerLeft,
            label: const Text('Menu'),
            onPressed: () {
              _openDrawer(context, screenSize);
            },
            child: const Icon(Icons.menu),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              if (screenSize != ScreenSize.small)
                NavBar(
                  expanded: expanded,
                  screenSize: screenSize,
                ),
              Expanded(
                  child: ShadcnApp.router(
                routerConfig: router,
                theme: themeNotifier!.currentTheme,
              ))
            ],
          ),
        )
      ],
    ));
  }

  void _openDrawer(BuildContext context, ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        openDrawer(
          context: context,
          expands: true,
          transformBackdrop: false,
          showDragHandle: false,
          builder: (context) {
            return NavBar(
              expanded: true,
              screenSize: screenSize,
            );
          },
          position: OverlayPosition.left,
        );
        break;
      default:
        setState(() {
          expanded = !expanded;
        });
        break;
    }
  }
}

class TitleBar extends StatefulWidget {
  final Widget? leading;
  const TitleBar({super.key, this.leading});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.leading != null) widget.leading!,
            Expanded(child: MoveWindow()),
            WindowButtons()
          ],
        ));
  }
}
