import 'package:chatfusion/dialog.dart';
import 'package:chatfusion/sheet.dart';
import 'package:chatfusion/tree.dart';
import 'package:chatfusion/window.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => DialogPage(),
    // builder: (context, state) => TestWidget(),
    name: 'home',
  ),
  GoRoute(
    path: '/tree',
    builder: (context, state) => TreePage(),
    name: 'tree',
  ),
  GoRoute(
    path: '/sheet',
    builder: (context, state) => SheetPage(),
    name: 'sheet',
  ),
  GoRoute(
    path: '/window',
    builder: (context, state) => WindowPage(),
    name: 'window',
  ),
];
