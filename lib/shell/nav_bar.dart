import 'package:chatfusion/shell/screen_size.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NavBar extends StatefulWidget {
  final bool expanded;
  final ScreenSize screenSize;
  const NavBar({
    super.key,
    required this.expanded,
    required this.screenSize,
  });
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selected = 0;
  bool expanded = false;
  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }

  NavigationItem buildButton(String text, IconData icon, String path) {
    return NavigationItem(
      label: Text(text),
      alignment: Alignment.centerLeft,
      selectedStyle: ButtonStyle.primaryIcon(),
      child: Icon(icon),
      onChanged: (value) {
        if (value) {
          context.goNamed(path);
        }
      },
    );
  }

  NavigationLabel buildLabel(String label) {
    return NavigationLabel(
      alignment: Alignment.centerLeft,
      child: Text(label).semiBold().muted(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.screenSize == ScreenSize.small)
          NavigationButton(
            alignment: Alignment.centerLeft,
            onPressed: () {},
            child: const Icon(Icons.menu),
          ),
        Expanded(
            child: NavigationRail(
          backgroundColor: theme.colorScheme.card,
          labelType: widget.expanded
              ? NavigationLabelType.expanded
              : NavigationLabelType.tooltip,
          labelPosition: NavigationLabelPosition.end,
          alignment: NavigationRailAlignment.start,
          labelSize: NavigationLabelSize.large,
          expanded: widget.expanded,
          index: selected,
          onSelected: (value) {
            setState(() {
              selected = value;
            });
          },
          children: [
            buildLabel('You'),
            buildButton('Home', Icons.dangerous, 'dialog'),
            buildButton('Trending', Icons.trending_up, 'tree'),
            // buildButton('Subscription', Icons.subscriptions,'dialog'),
            NavigationDivider(),
            buildLabel('History'),
            buildButton('History', Icons.history, 'window'),
            buildButton('Watch Later', Icons.access_time_rounded, 'sheet'),
          ],
        )),
      ],
    );
  }
}
