import 'package:shadcn_flutter/shadcn_flutter.dart';

enum ScreenSize {
  small,
  medium,
  large,
  
}

ScreenSize getScreenSize(BuildContext context) {
  if (MediaQuery.of(context).size.width < 600) {
    return ScreenSize.small;
  } else if (MediaQuery.of(context).size.width < 900) {
    return ScreenSize.medium;
  } else {
    return ScreenSize.large;
  }
}
