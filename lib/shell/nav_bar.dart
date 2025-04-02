import 'package:chatfusion/routes.dart';
import 'package:chatfusion/shell/screen_size.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NavBar extends StatefulWidget {
  bool? expanded;
  final ScreenSize screenSize;
  bool? isDrawer;
  int selected;
  final List<RouteItem> items;
  final ValueChanged<int>? onSelected;
  NavBar({
    super.key,
    this.expanded = true,
    required this.screenSize,
    this.isDrawer = false,
    required this.selected,
    this.onSelected,
    required this.items,
  });
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool expanded = true;
  @override
  void initState() {
    super.initState();
    expanded = widget.expanded!;
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
          if (widget.isDrawer!) {
            closeSheet(context);
          }
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: Container(
          width: widget.isDrawer! ? 150 : null,
          alignment: Alignment.topLeft,
          margin: widget.isDrawer! ? EdgeInsets.zero : EdgeInsets.all(0),
          child: NavigationRail(
            backgroundColor: theme.colorScheme.card,
            labelType: widget.expanded!
                ? NavigationLabelType.expanded
                : NavigationLabelType.tooltip,
            labelPosition: NavigationLabelPosition.end,
            alignment: NavigationRailAlignment.start,
            labelSize: NavigationLabelSize.large,
            expanded: widget.expanded!,
            index: widget.selected,
            onSelected: (value) {
              if (widget.onSelected != null) {
                widget.onSelected!(value);
              }
            },
            children: _buildItems(),
          ),
        )),
      ],
    );
  }

  List<NavigationBarItem> _buildItems() {
    List<NavigationBarItem> items = [];
    widget.items.forEach((element) {
      if (element.hsaDivider!) {
        items.add(NavigationDivider());
      }
      if (element.label != null) {
        items.add(buildLabel(element.label!));
      }
      items.add(buildButton(element.title, element.icon, element.route.name!));
    });
    return items;
  }
}
