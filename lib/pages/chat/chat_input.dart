import 'package:chatfusion/notifier/settings.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as m;

class ChatInput extends StatefulWidget {
  String? model;
  Map<String, String>? supportModels;
  final double maxWidth;
  bool done;
  void Function(String)? onSubmit;
  void Function(String?)? onModelChange;
  ChatInput({
    super.key,
    required this.maxWidth,
    this.onSubmit,
    this.onModelChange,
    this.model,
    this.supportModels,
    this.done = false,
  });
  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController textEditingController = TextEditingController();
  SettingsNotifier? settingsNotifier;
  bool network = false;
  bool think = false;
  String? model;
  bool focused = false;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    settingsNotifier = Provider.of<SettingsNotifier>(context, listen: true);
  }

  void _updateUi() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Chip(
              style: think
                  ? const ButtonStyle.primary()
                  : const ButtonStyle.outline(),
              child: ChipButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(think
                        ? BootstrapIcons.lightbulbFill
                        : BootstrapIcons.lightbulbOffFill),
                    SizedBox(
                      width: 5,
                    ),
                    Text("深度思考")
                  ],
                ),
                onPressed: () {
                  setState(() {
                    think = !think;
                  });
                },
              ),
            ),
            Chip(
              style: network
                  ? const ButtonStyle.primary()
                  : const ButtonStyle.outline(),
              child: ChipButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(BootstrapIcons.globe),
                    SizedBox(
                      width: 5,
                    ),
                    Text("联网搜索")
                  ],
                ),
                onPressed: () {
                  setState(() {
                    network = !network;
                  });
                },
              ),
            ),
            _buildModelWidget()
          ],
        ),
        SizedBox(height: 10),
        Card(
          borderColor: focused
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          child: IntrinsicHeight(
              child: Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.enter): SubmitActionIndent(),
                LogicalKeySet(
                        LogicalKeyboardKey.shift, LogicalKeyboardKey.enter):
                    InsertNewLineIntent()
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  SubmitActionIndent: CallbackAction(
                    onInvoke: (intent) {
                      sendMessage();
                      return true;
                    },
                  ),
                  InsertNewLineIntent: CallbackAction(onInvoke: (intent) {
                    textEditingController.text += "\n";
                    return true;
                  }),
                },
                child: Focus(
                    autofocus: false,
                    onFocusChange: (value) {
                      setState(() {
                        focused = value;
                      });
                    },
                    focusNode: FocusNode(),
                    child: TextField(
                      border: false,
                      controller: textEditingController,
                      placeholder: Text(
                        "Type your message here...",
                      ),
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      features: [
                        InputFeature.trailing(
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Button(
                              onPressed: sendMessage,
                              style: ButtonStyle.outlineIcon(
                                shape: ButtonShape.circle,
                              ).withBorder(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: RepeatedAnimationBuilder<double>(
                                start: 0.8,
                                end: 1,
                                duration: const Duration(milliseconds: 1200),
                                reverseDuration:
                                    const Duration(milliseconds: 1200),
                                mode: RepeatMode.pingPongReverse,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Icon(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      widget.done
                                          ? BootstrapIcons.fastForwardFill
                                          : BootstrapIcons.stopFill,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          )),
        )
      ],
    );
  }

  void sendMessage() {
    if (widget.onSubmit != null) {
      widget.onSubmit!(textEditingController.text);
    }
    textEditingController.clear();
  }

  Widget _buildModelWidget() {
    List<SelectItemButton> items = [];
    if (widget.supportModels != null) {
      widget.supportModels!.forEach((k, v) {
        items.add(SelectItemButton(
          value: k,
          child: Text(v),
        ));
      });
    }

    return Select<String>(
      constraints: BoxConstraints(maxHeight: 28, minWidth: 170),
      padding: EdgeInsets.all(4.5),
      itemBuilder: (context, item) {
        return Text(widget.supportModels![item]!);
      },
      popupConstraints: const BoxConstraints(
        maxHeight: 300,
      ),
      onChanged: (value) {
        setState(() {
          model = value;
        });
        if (widget.onModelChange != null) {
          widget.onModelChange!(value);
        }
      },
      value: model,
      placeholder: Text('Select a model'),
      popup: SelectPopup(
        items: SelectItemList(
          children: items,
        ),
      ).call,
    );
  }
}

class SubmitActionIndent extends Intent {}

class InsertNewLineIntent extends Intent {}
