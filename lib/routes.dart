import 'package:chatfusion/dialog.dart';
import 'package:chatfusion/pages/chat/index.dart';
import 'package:chatfusion/pages/example/dropdown.dart';
import 'package:chatfusion/pages/example/test.dart';
import 'package:chatfusion/sheet.dart';
import 'package:chatfusion/shell/shell.dart';
import 'package:chatfusion/tree.dart';
import 'package:chatfusion/window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class RouteItem {
  final String title;
  final GoRoute route;
  final IconData icon;
  String? label;
  bool? hsaDivider;
  RouteItem({
    required this.title,
    required this.route,
    required this.icon,
    this.label,
    this.hsaDivider = false,
  });
}

List<RouteItem> routeItems = [
  RouteItem(
    label: 'Basic',
    title: 'Home',
    icon: RadixIcons.home,
    route: GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: DialogPage(), key: state.pageKey),
      name: 'home',
    ),
  ),
  RouteItem(
    title: 'Tree',
    icon: RadixIcons.globe,
    route: GoRoute(
      path: '/tree',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: TreePage(), key: state.pageKey),
      name: 'tree',
    ),
  ),
  RouteItem(
    label: 'Advanced',
    title: 'Sheet',
    icon: RadixIcons.keyboard,
    hsaDivider: true,
    route: GoRoute(
      path: '/sheet',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: SheetPage(), key: state.pageKey),
      name: 'sheet',
    ),
  ),
  RouteItem(
    title: 'Win',
    icon: RadixIcons.magicWand,
    route: GoRoute(
      path: '/window',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: WindowPage(), key: state.pageKey),
      name: 'window',
    ),
  ),
  RouteItem(
    title: 'Drop',
    icon: RadixIcons.drawingPin,
    route: GoRoute(
      path: '/dropdown',
      pageBuilder: (context, state) => _buildPageWithTransition(
          child: DropdownMenuExample(), key: state.pageKey),
      name: 'dropdown',
    ),
  ),
  RouteItem(
    title: 'chat'.tr(),
    icon: BootstrapIcons.chatText,
    route: GoRoute(
      path: '/chat',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: ChatPage(), key: state.pageKey),
      name: 'chat',
    ),
  ),
  RouteItem(
    title: 'Test',
    icon: RadixIcons.drawingPin,
    route: GoRoute(
      path: '/test',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: TestPage(), key: state.pageKey),
      name: 'test',
    ),
  ),
];

final List<RouteBase> routes = [
  ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (context, state, child) {
        return AppShell(
          body: child,
          items: routeItems,
        );
      },
      routes: routeItems.map((e) => e.route).toList())
];

Page<void> _buildPageWithTransition(
    {required Widget child, required ValueKey key}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
