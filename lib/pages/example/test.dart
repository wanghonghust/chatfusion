import 'package:chatfusion/widgets/edge_tab/controller.dart';
import 'package:chatfusion/widgets/edge_tab/index.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TestPageState();
  }
}

class _TestPageState extends State<TestPage> {
  EdgeTabController controller = EdgeTabController(selectedIndex: 0, items: [
    EdgeTabItem(label: "Home", icon: Icon(Icons.home), body: Text("Home")),
    EdgeTabItem(label: "Add", icon: Icon(Icons.add), body: Text("Add")),
    EdgeTabItem(label: "Home", icon: Icon(Icons.home), body: Text("Home")),
    EdgeTabItem(
        label: "FaceRecognition",
        icon: Icon(Icons.face),
        body: Text("FaceRecognition")),
  ]);
  @override
  Widget build(BuildContext context) {
    return EdgeTab(
      controller: controller,
      defaultTab: EdgeTabItem(
        label: "New Tab",
        icon: Icon(Icons.tab),
        body: Center(
          child: Text("New Tab"),
        ),
      ),
    );
  }
}
