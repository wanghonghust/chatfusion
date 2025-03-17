import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class WindowPage extends StatefulWidget{
  @override
  _WindowPageState createState() => _WindowPageState();
}

class _WindowPageState extends State<WindowPage> {
  final GlobalKey<WindowNavigatorHandle> navigatorKey = GlobalKey();
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OutlinedContainer(
        height: 600, // for example purpose
        child: WindowNavigator(
          key: navigatorKey,
          child: const Center(
            child: Text('Desktop'),
          ),
          initialWindows: [
            Window(
              bounds: Rect.fromLTWH(0, 0, 200, 200),
              title: Text('Window 1'),
              content: const Text("Hello World"),
            ),
            Window(
              bounds: Rect.fromLTWH(200, 0, 200, 200),
              title: Text('Window 2'),
              content: const Text("Hello World"),
            ),
          ],
        ),
      ),
      PrimaryButton(
        child: const Text('Add Window'),
        onPressed: () {
          navigatorKey.currentState?.pushWindow(
            Window(
              bounds: Rect.fromLTWH(0, 0, 200, 200),
              title: Text(
                  'Window ${navigatorKey.currentState!.windows.length + 1}'),
              content: const Text("Hello World"),
            ),
          );
        },
      )
    ],
  );
}

}