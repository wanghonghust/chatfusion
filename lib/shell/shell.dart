import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chatfusion/notifier/settings.dart';
import 'package:chatfusion/pages/settings/api_key.dart';
import 'package:chatfusion/pages/settings/index.dart';
import 'package:chatfusion/routes.dart';
import 'package:chatfusion/shell/nav_bar.dart';
import 'package:chatfusion/shell/screen_size.dart';
import 'package:chatfusion/shell/window_buttons.dart';
import 'package:chatfusion/utils/item.dart';
import 'package:chatfusion/widgets/svg_icon.dart';
import 'package:easy_localization/easy_localization.dart';
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
  SettingsNotifier? settingsNotifier;
  bool expanded = true;
  int selected = 0;

  @override
  void dispose() {
    if (settingsNotifier != null) {
      settingsNotifier!.removeListener(_updateUi);
    }
    super.dispose();
  }

  void _updateUi() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    settingsNotifier = Provider.of<SettingsNotifier>(context, listen: true);
    settingsNotifier!.init();
    if (settingsNotifier != null) {
      settingsNotifier!.addListener(_updateUi);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = getScreenSize(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      headers: [
        SafeArea(
          child: TitleBar(
            leading: NavigationButton(
              alignment: Alignment.centerLeft,
              onPressed: () {
                _openDrawer(context, screenSize);
              },
              child: SvgIcon(
                size: 18,
                expanded
                    ? "assets/svg/hide-sidebar-horiz.svg"
                    : "assets/svg/show-sidebar-horiz.svg",
              ),
            ),
          ),
        )
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
          Expanded(
            child: widget.body,
          )
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
          showDragHandle: true,
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
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.card,
            border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.border))),
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.leading != null) widget.leading!,
            Expanded(child: MoveWindow()),
            IconButton.ghost(
              onPressed: showSettings,
              density: ButtonDensity.icon,
              icon: Icon(BootstrapIcons.gearWideConnected),
            ),
            Builder(builder: (context) {
              return IconButton.ghost(
                onPressed: () => showUserDropDown(context),
                density: ButtonDensity.icon,
                icon: Icon(BootstrapIcons.personGear),
              );
            }),
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
                  Icon(BootstrapIcons.gearWideConnected),
                  SizedBox(
                    width: 10,
                  ),
                  Text('settings'.tr()),
                ],
              )),
              IconButton.ghost(
                onPressed: () {
                  Navigator.of(context).pop(controller.values);
                },
                shape: ButtonShape.circle,
                icon: const Icon(BootstrapIcons.x),
              ),
            ],
          ),
          content: SettingsPage(),
        );
      },
    );
  }

  void showUserDropDown(BuildContext context) {
    showDropdown(
      context: context,
      builder: (_) {
        return DropdownMenu(
          children: [
            const MenuLabel(child: Text('My Account')),
            const MenuDivider(),
            MenuButton(
              child: const Text('API KEY 配置'),
              onPressed: (_) {
                showApiKeyDialog(context, onEnd: (success) {
                  if (success) {
                    showToast(
                      context: context,
                      location: ToastLocation.bottomRight,
                      showDuration: Duration(seconds: 2),
                      builder: buildToast,
                    );
                  }
                });
              },
            ),
            const MenuButton(
              child: Text('Billing'),
            ),
            const MenuButton(
              child: Text('Settings'),
            ),
            const MenuButton(
              child: Text('Keyboard shortcuts'),
            ),
            const MenuDivider(),
            const MenuButton(
              child: Text('Team'),
            ),
            const MenuButton(
              subMenu: [
                MenuButton(
                  child: Text('Email'),
                ),
                MenuButton(
                  child: Text('Message'),
                ),
                MenuDivider(),
                MenuButton(
                  child: Text('More...'),
                ),
              ],
              child: Text('Invite users'),
            ),
            const MenuButton(
              child: Text('New Team'),
            ),
            const MenuDivider(),
            const MenuButton(
              child: Text('GitHub'),
            ),
            const MenuButton(
              child: Text('Support'),
            ),
            const MenuButton(
              enabled: false,
              child: Text('API'),
            ),
            const MenuButton(
              child: Text('Log out'),
            ),
          ],
        );
      },
    ).future.then((_) {});
  }
}
