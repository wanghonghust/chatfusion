import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/notifier/theme.dart';
import 'package:chatfusion/pages/settings/index.dart';
import 'package:chatfusion/routes.dart';
import 'package:chatfusion/shell/nav_bar.dart';
import 'package:chatfusion/shell/screen_size.dart';
import 'package:chatfusion/shell/window_buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  final Widget body;
  final List<RouteItem> items;
  const AppShell({
    super.key,
    required this.body,
    required this.items,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ThemeNotifier? themeNotifier;
  bool expanded = true;
  int selected = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    themeNotifier!.init();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = getScreenSize(context);
    return Scaffold(
      headers: [
        TitleBar(
          leading: NavigationButton(
            alignment: Alignment.centerLeft,
            onPressed: () {
              _openDrawer(context, screenSize);
            },
            child: const Icon(Icons.menu),
          ),
        ),
      ],
      child: Row(
        children: [
          if (screenSize != ScreenSize.small)
            NavBar(
              items: widget.items,
              expanded: expanded,
              screenSize: screenSize,
              selected: selected,
              onSelected: _onSelected,
            ),
          Expanded(child: widget.body)
        ],
      ),
    );
  }

  void _openDrawer(BuildContext context, ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        openDrawer(
          context: context,
          // barrierColor: Colors.transparent,
          expands: true,
          transformBackdrop: false,
          showDragHandle: false,
          builder: (context) {
            return NavBar(
              items: widget.items,
              screenSize: screenSize,
              isDrawer: true,
              selected: selected,
              onSelected: _onSelected,
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

  void _onSelected(int index) {
    setState(() {
      selected = index;
    });
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
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.foreground.withAlpha(20),
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              )
            ]),
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.leading != null) widget.leading!,
            Expanded(child: MoveWindow()),
            IconButton.ghost(
              onPressed: showSettings,
              density: ButtonDensity.icon,
              icon: const Icon(Icons.settings),
            ),
            WindowButtons()
          ],
        ));
  }

  void showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        final FormController controller = FormController();
        return AlertDialog(
          padding: EdgeInsets.all(5),
          title: Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(
                    width: 10,
                  ),
                  Text('设置'),
                ],
              )),
              IconButton.ghost(
                onPressed: () {
                  Navigator.of(context).pop(controller.values);
                },
                shape: ButtonShape.circle,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SettingsPage(),
        );
      },
    );
  }
}
