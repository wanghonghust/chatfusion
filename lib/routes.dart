import 'package:chatfusion/dialog.dart';
import 'package:chatfusion/main.dart';
import 'package:chatfusion/sheet.dart';
import 'package:chatfusion/shell/shell.dart';
import 'package:chatfusion/tab_pane.dart';
import 'package:chatfusion/tree.dart';
import 'package:chatfusion/window.dart';
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
    icon: Icons.home,
    route: GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: DialogPage(), key: state.pageKey),
      name: 'home',
    ),
  ),
  RouteItem(
    title: 'Tree',
    icon: Icons.collections,
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
    icon: Icons.shelves,
    hsaDivider: true,
    route: GoRoute(
      path: '/sheet',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: SheetPage(), key: state.pageKey),
      name: 'sheet',
    ),
  ),
  RouteItem(
    title: 'Window',
    icon: Icons.window,
    route: GoRoute(
      path: '/window',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: WindowPage(), key: state.pageKey),
      name: 'window',
    ),
  ),
  RouteItem(
    title: 'Tab',
    icon: Icons.tab,
    route: GoRoute(
      path: '/tab',
      pageBuilder: (context, state) => _buildPageWithTransition(
          child: TabPaneExample1(), key: state.pageKey),
      name: 'tab',
    ),
  ),
];

final List<RouteBase> routes = [
  ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (context, state, child) {
        return Scaffold(
            child: AppShell(
          body: child,
          items: routeItems,
        ));
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
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
