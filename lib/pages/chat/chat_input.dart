import 'package:chatfusion/notifier/settings.dart';
import 'package:chatfusion/pages/chat/chip_toggle.dart';
import 'package:chatfusion/widgets/svg_icon.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as m;

class ChatInput extends StatefulWidget {
  String? model;
  Map<String, String>? supportModels;
  final double maxWidth;
  bool done;
  void Function(String)? onSubmit;
  void Function(String?)? onModelChange;
  void Function(bool)? onAutoScrollChange;
  ChatInput({
    super.key,
    required this.maxWidth,
    this.onSubmit,
    this.onModelChange,
    this.onAutoScrollChange,
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
  bool autoScroll = true;

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
            ChipToggle(
              value: think,
              icon: Icon(think
                  ? BootstrapIcons.lightbulbFill
                  : BootstrapIcons.lightbulbOffFill),
              onPressed: () {
                setState(() {
                  think = !think;
                });
              },
              child: Text("深度思考"),
            ),
            ChipToggle(
              value: network,
              icon: Icon(network ? LucideIcons.globe : LucideIcons.globeLock),
              onPressed: () {
                setState(() {
                  network = !network;
                });
              },
              child: Text("联网搜索"),
            ),
            ChipToggle(
              value: autoScroll,
              icon: Icon(autoScroll
                  ? BootstrapIcons.lightbulbFill
                  : BootstrapIcons.lightbulbOffFill),
              onPressed: () {
                setState(() {
                  autoScroll = !autoScroll;
                });
              },
              child: Text("自动滚动"),
            ),
            _buildModelWidget()
          ],
        ),
        SizedBox(height: 10),
        Card(
          borderColor: focused
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.border,
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
                        'chat_placeholder'.tr(),
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
                                size: ButtonSize.xSmall,
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
                                    child: SvgIcon(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      widget.done
                                          ? "assets/svg/send.svg"
                                          : "assets/svg/stop.svg",
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
