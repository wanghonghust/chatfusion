import 'package:shadcn_flutter/shadcn_flutter.dart';

class SheetPage extends StatefulWidget {
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  List<OverlayPosition> positions = [
    OverlayPosition.left,
    OverlayPosition.left,
    OverlayPosition.bottom,
    OverlayPosition.bottom,
    OverlayPosition.top,
    OverlayPosition.top,
    OverlayPosition.right,
    OverlayPosition.right,
  ];
  void open(BuildContext context, int count) {
    openDrawer(
      context: context,
      expands: true,
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(48),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    'Drawer ${count + 1} at ${positions[count % positions.length].name}'),
                const Gap(16),
                PrimaryButton(
                  onPressed: () {
                    open(context, count + 1);
                  },
                  child: const Text('Open Another Drawer'),
                ),
                const Gap(8),
                SecondaryButton(
                  onPressed: () {
                    closeOverlay(context);
                  },
                  child: const Text('Close Drawer'),
                ),
              ],
            ),
          ),
        );
      },
      position: positions[count % positions.length],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrimaryButton(
            onPressed: () {
              open(context, 0);
            },
            child: const Text('Open Drawer'),
          )
        ]);
  }
}
