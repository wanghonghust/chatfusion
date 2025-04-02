import 'package:shadcn_flutter/shadcn_flutter.dart';

void showCusDialog(
  BuildContext context, {
  required Widget child,
  required Widget title,
  Widget? icon,
}) {
  final FormController controller = FormController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        padding: EdgeInsets.all(5),
        title: Row(
          children: [
            Expanded(
                child: Row(
              children: [
                icon ?? SizedBox.shrink(),
                SizedBox(
                  width: 10,
                ),
                title,
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
        content: child,
      );
    },
  );
}

void showAlert(
  BuildContext context, {
  required Widget title,
  required Widget content,
  Function? onConfirm,
  Function? onCancel,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          OutlineButton(
            size: ButtonSize.small,
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
              if (onCancel != null) {
                onCancel();
              }
            },
          ),
          PrimaryButton(
            size: ButtonSize.small,
            child: const Text('确定'),
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) {
                onConfirm();
              }
            },
          ),
        ],
      );
    },
  );
}
