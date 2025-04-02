import 'package:chatfusion/widgets/edge_tab/index.dart';
import 'package:flutter/material.dart';

class EdgeTabController extends ChangeNotifier {
  // 当前选中的索引
  int selectedIndex;
  // TabItem列表
  List<EdgeTabItem> items;

  EdgeTabController({required this.selectedIndex, required this.items});

  List<Widget> getContents() {
    return items.map((item) => item.body).toList();
  }

  // 切换Tab
  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void addTab(EdgeTabItem item, {bool selectLast = false}) {
    items.add(item);
    if (selectLast) {
      selectedIndex = items.length - 1;
    }
    notifyListeners();
  }

  void insertTab(EdgeTabItem item, int index) {
    items.insert(index, item);
    notifyListeners();
  }

  EdgeTabItem? removeTab(int index) {
    if (index >= 0 && index < items.length) {
      var item = items.removeAt(index);
      if (items.isEmpty) {
        selectedIndex = -1;
        notifyListeners();
        return item;
      }
      if (index <= selectedIndex) {
        selectedIndex = selectedIndex - 1;
      } else {
        selectedIndex = selectedIndex;
      }
      if (selectedIndex < 0) {
        selectedIndex = 0;
      }
      notifyListeners();
      return item;
    }
    notifyListeners();
    return null;
  }
}
