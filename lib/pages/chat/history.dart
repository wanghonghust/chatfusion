import 'package:chatfusion/database/models/message.dart';
import 'package:chatfusion/pages/chat/index.dart';
import 'package:chatfusion/widgets/markdown/index.dart';
import 'package:flutter/material.dart' show MaterialTextSelectionControls;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class History extends StatefulWidget {
  final List<Message> messages;
  ScrollController? scrollController;
  History({super.key, required this.messages, this.scrollController});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ListView.builder(
        controller: widget.scrollController,
        itemBuilder: (context, index) {
          var item = widget.messages[index];
          final String content = item.content;
          final String? bubbleModel = item.role == 0 ? null : item.model;
          return Padding(
            padding: EdgeInsets.all(10),
            child: _buildChatBubble(
                Column(children: [
                  if (item.thinkContent != null)
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      )),
                      child: MarkdownWidget(
                        text: item.thinkContent!.trim(),
                      ),
                    ),
                  if (item.thinkContent != null) Divider(),
                  if (bubbleModel == null)
                    SelectableRegion(
                        focusNode: FocusNode(),
                        selectionControls: materialTextControls,
                        child: Text(
                          content.trim(),
                          style: TextStyle(fontSize: 14),
                        ))
                  else
                    MarkdownWidget(
                      text: content,
                    )
                ]),
                bubbleModel),
          );
        },
        itemCount: widget.messages.length,
      );
    });
  }

  Widget _buildChatBubble(Widget child, String? model) {
    Widget mesageWidget = Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.card,
          borderRadius: BorderRadius.circular(5)),
      child: child,
    );
    return Align(
      alignment: model == null ? Alignment.centerRight : Alignment.centerLeft,
      child: model == null
          ? mesageWidget
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.card,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      supportModels[model] ?? model,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                mesageWidget
              ],
            ),
    );
  }
}
