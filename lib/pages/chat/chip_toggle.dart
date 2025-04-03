import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ChipToggle extends StatelessWidget {
  final bool value;
  final Widget? icon;
  final Widget child;
  final void Function() onPressed;
  const ChipToggle({
    super.key,
    required this.value,
    required this.onPressed,
    this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      style: value
          ? ButtonStyle.primary().copyWith(
              decoration: (context, states, value) =>
                  value.copyWithIfBoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : ButtonStyle.outline().copyWith(
              decoration: (context, states, value) =>
                  value.copyWithIfBoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.border,
                ),
              ),
            ),
      child: ChipButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
