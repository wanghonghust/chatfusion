import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SvgIcon extends StatelessWidget {
  final String asset;
  final double? size;
  final Color? color;
  const SvgIcon(this.asset, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
          color ?? Theme.of(context).colorScheme.foreground, BlendMode.srcIn),
    );
  }
}
