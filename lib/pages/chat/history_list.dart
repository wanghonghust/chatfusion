import 'package:chatfusion/database/models/conversation.dart';
import 'package:chatfusion/pages/chat/controller.dart';
import 'package:chatfusion/shell/screen_size.dart'
    show ScreenSize, getScreenSize;
import 'package:chatfusion/widgets/svg_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

class GroupedConversation {
  final String title;
  final List<Conversation> conversations;
  GroupedConversation({required this.title, required this.conversations});
}

class HistoryList extends StatefulWidget {
  final Function(Conversation conversation)? onSelected;
  final VoidCallback? onNewConversation;
  final Function(Conversation)? onDeleteConversation;
  final Function(Conversation)? onRenameDone;
  const HistoryList({
    super.key,
    this.onSelected,
    this.onRenameDone,
    this.onNewConversation,
    this.onDeleteConversation,
  });

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  int hoverindex = -1;
  ChatController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = Provider.of<ChatController>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = getScreenSize(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
        borderColor: screenSize == ScreenSize.small ? Colors.transparent : null,
        padding: EdgeInsets.all(5),
        borderRadius: BorderRadius.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.onNewConversation != null)
              TextButton(
                size: ButtonSize.xSmall,
                onPressed: widget.onNewConversation,
                trailing: SvgIcon(
                  "assets/svg/message-add.svg",
                  size: 18,
                ),
                child: const Text(
                  '新建对话',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            if (widget.onNewConversation != null) Divider(),
            Text('历史对话',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                .mono,
            Expanded(child: _buildList(controller!.histories)),
          ],
        ),
      );
    });
  }

  Widget _buildList(List<Conversation> items) {
    var groupedItems = _groupItemsByDate(items);
    return ListView.builder(
      itemBuilder: (context, index) {
        var item = groupedItems[index];
        List<Widget> groupWidgetItems = [];
        item.conversations.forEach((ele) {
          groupWidgetItems.add(NavItem(
            conversation: ele,
            isEditing: controller!.renameConversation == ele,
            selected: controller!.conversation == ele,
            onFocusChange: (value) {
              if (!value) {
                controller!.renameConversation = null;
              }
            },
            onRenameDone: (value) {
              controller!.renameConversation = null;
              if (widget.onRenameDone != null) {
                widget.onRenameDone!(ele);
              }
            },
            onPressed: () {
              if (widget.onSelected != null) {
                widget.onSelected!(ele);
              }
            },
            onMore: (context) {
              if (widget.onSelected != null) {
                widget.onSelected!(ele);
              }
              _onMore(context, ele);
            },
          ));
        });
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ).mono),
            ),
            ...groupWidgetItems,
            if (index != groupedItems.length - 1) Divider(),
          ],
        );
      },
      itemCount: groupedItems.length,
    );
  }

  void _onMore(BuildContext context, Conversation conversation) {
    showDropdown(
        context: context,
        anchorAlignment: Alignment.bottomRight,
        builder: (context) {
          return DropdownMenu(children: [
            MenuButton(
              trailing: MenuShortcut(
                activator: SingleActivator(
                  LogicalKeyboardKey.keyR,
                  control: true,
                ),
              ),
              leading: Icon(BootstrapIcons.replyFill),
              child: Text('重命名'),
              onPressed: (context) {
                controller!.renameConversation = conversation;
              },
            ),
            MenuButton(
                trailing: MenuShortcut(
                  activator: SingleActivator(
                    LogicalKeyboardKey.keyS,
                    shift: true,
                  ),
                ),
                leading: Icon(BootstrapIcons.shareFill),
                child: Text('分享对话'),
                onPressed: (context) {}),
            MenuButton(
                trailing: MenuShortcut(
                  activator: SingleActivator(
                    LogicalKeyboardKey.keyT,
                    control: true,
                  ),
                ),
                leading: Icon(BootstrapIcons.pinAngleFill),
                child: Text('置顶对话'),
                onPressed: (context) {}),
            MenuDivider(),
            MenuButton(
              trailing: MenuShortcut(
                activator: SingleActivator(
                  LogicalKeyboardKey.delete,
                  control: true,
                ),
              ),
              leading: Icon(BootstrapIcons.trashFill),
              child: Text('删除对话'),
              onPressed: (context) {
                Conversation.deleteConversation(conversation.id!).then(
                  (value) {
                    if (widget.onDeleteConversation != null) {
                      widget.onDeleteConversation!(conversation);
                    }
                  },
                );
              },
            ),
          ]);
        });
  }

  List<GroupedConversation> _groupItemsByDate(List<Conversation> items) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day); // 今日的起始时间
    List<GroupedConversation> grouped = [];

    // 今日
    var itemsToday = items.where((item) {
      return item.createAtDateTime!.isAfter(startOfDay); // 今日的数据
    }).toList();
    if (itemsToday.isNotEmpty) {
      grouped.add(GroupedConversation(
        title: '今日',
        conversations: itemsToday,
      ));
    }

    // 最近7天（排除今日）
    var itemsLast7Days = items.where((item) {
      return item.createAtDateTime!.isAfter(now.subtract(Duration(days: 7))) &&
          item.createAtDateTime!.isBefore(startOfDay); // 排除今日
    }).toList();
    if (itemsLast7Days.isNotEmpty) {
      grouped.add(GroupedConversation(
        title: '最近7天',
        conversations: itemsLast7Days,
      ));
    }
    // 前30天（排除今日和最近7天的数据）
    var itemsBefore30Days = items.where((item) {
      return item.createAtDateTime!.isAfter(now.subtract(Duration(days: 30))) &&
          item.createAtDateTime!
              .isBefore(now.subtract(Duration(days: 7))); // 排除最近7天
    }).toList();
    if (itemsBefore30Days.isNotEmpty) {
      grouped.add(GroupedConversation(
        title: '前30天',
        conversations: itemsBefore30Days,
      ));
    }

    return grouped;
  }
}

class NavItem extends StatefulWidget {
  final Conversation conversation;
  final bool selected;
  final bool isEditing;
  final Function()? onPressed;
  final Function(bool)? onFocusChange;
  final Function(String)? onRenameDone;
  final Function(BuildContext context)? onMore;
  const NavItem({
    super.key,
    required this.conversation,
    this.onPressed,
    this.onFocusChange,
    this.onRenameDone,
    this.onMore,
    this.selected = false,
    this.isEditing = false,
  });

  @override
  _NavItemState createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool hover = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.conversation.title;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2),
      child: Container(
        padding: widget.isEditing
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: widget.selected
                ? Theme.of(context).colorScheme.primary
                : (hover
                    ? Theme.of(context).colorScheme.accent
                    : Colors.transparent)),
        child: widget.isEditing
            ? TextField(
                style: TextStyle(fontSize: 14),
                focusNode: _focusNode,
                autofocus: true,
                controller: _controller,
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                trailing: IconButton.ghost(
                  size: ButtonSize.xSmall,
                  icon: Icon(Icons.check),
                  onPressed: () {
                    Conversation.changeTitle(
                        widget.conversation.id!, _controller.text);
                    if (widget.onRenameDone != null) {
                      widget.onRenameDone!(_controller.text);
                    }
                  },
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(5),
                ),
                cursorColor: Colors.white,
                onTapOutside: (value) {
                  if (widget.onFocusChange != null) {
                    widget.onFocusChange!(false);
                  }
                })
            : InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  if (widget.onPressed != null) {
                    widget.onPressed!();
                  }
                },
                onHover: (value) {
                  setState(() {
                    hover = value;
                  });
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        maxLines: 1,
                        widget.conversation.title,
                        style: TextStyle(
                            fontSize: 14, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    if (hover)
                      InkWell(
                        child: Icon(
                          Icons.more_horiz,
                          size: 14,
                        ),
                        onTap: () {
                          if (widget.onMore != null) {
                            widget.onMore!(context);
                          }
                        },
                      )
                  ],
                ),
              ),
      ),
    );
  }
}
