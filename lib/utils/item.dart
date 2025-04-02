import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget buildToast(BuildContext context, ToastOverlay overlay) {
  var date = DateTime.now();
  return SurfaceCard(
    child: Basic(
      title: const Text('API Key 保存成功', style: TextStyle(color: Colors.green)),
      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(date)),
    ),
  );
}
