import 'dart:async';

import 'package:chatfusion/database/models/conversation.dart';
import 'package:chatfusion/database/models/message.dart';
import 'package:chatfusion/notifier/settings.dart';
import 'package:chatfusion/pages/chat/chat_input.dart';
import 'package:chatfusion/pages/chat/controller.dart';
import 'package:chatfusion/pages/chat/history.dart';
import 'package:chatfusion/pages/chat/history_list.dart';
import 'package:chatfusion/pages/settings/api_key.dart';
import 'package:chatfusion/shell/screen_size.dart'
    show ScreenSize, getScreenSize;
import 'package:chatfusion/utils/item.dart';
import 'package:chatfusion/widgets/dialog.dart';
import 'package:chatfusion/widgets/svg_icon.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart' as p;
import 'package:flutter/material.dart' show Consumer;

const Map<String, String> supportModels = {
  "qwen-max-latest": "通义千问-Max-Latest",
  "qwen-max": "通义千问-Max",
  "qwen-plus": "通义千问 Plus",
  "deepseek-r1": "DeepSeek R1",
  "deepseek-v3": "DeepSeek V3",
};

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? model;
  List<Widget> items = [];
  bool done = true;
  List<Message> orderedMessages = [];
  final ScrollController _msgScrollController = ScrollController();
  bool think = false;
  bool network = false;
  bool autoScroll = true;
  bool selectModel = false;
  bool isThinking = false;
  StreamSubscription? subscription;
  StringBuffer responseBuffer = StringBuffer();
  StringBuffer thinkBuffer = StringBuffer();
  Message? userMsg;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  ChatController? controller;
  String? apiKey;
  @override
  void initState() {
    super.initState();
    model = supportModels.keys.first;
    OpenAI.baseUrl = "https://dashscope.aliyuncs.com/compatible-mode";
    getHistory();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = p.Provider.of<ChatController>(context, listen: true);
  }

  void getHistory() async {
    var res = await Conversation.getConversations(asc: false);
    controller!.histories = res;
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = getScreenSize(context);
    return Row(
      children: [
        if (screenSize != ScreenSize.small)
          SizedBox(
            width: 120,
            child: buildHistoryList(context, screenSize),
          ),
        Expanded(
          child: buildChatView(context, screenSize),
        ),
      ],
    );
  }

  Widget buildChatView(BuildContext context, ScreenSize screenSize) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Stack(children: [
        if (screenSize == ScreenSize.small)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton.ghost(
              icon: SvgIcon(
                "assets/svg/message-add.svg",
                size: 24,
              ),
              onPressed: onNewConversation,
            ),
            IconButton.ghost(
              icon: SvgIcon(
                "assets/svg/history.svg",
                size: 24,
              ),
              onPressed: () => openHistoryDrawer(context, screenSize),
            ),
          ]),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                controller!.conversation != null
                    ? controller!.conversation!.title
                    : 'new_chat'.tr(),
              ).bold,
            ),
            Expanded(
              child: History(
                messages: orderedMessages,
                scrollController: _msgScrollController,
              ),
            ),
            ChatInput(
              maxWidth: 500,
              supportModels: supportModels,
              onSubmit: (msg) {
                chat(context, msg);
              },
              onAutoScrollChange: (v) {
                setState(() {
                  autoScroll = v;
                });
              },
              model: model,
              done: done,
              onModelChange: (v) {
                setState(() {
                  model = v;
                });
              },
            ),
          ],
        )
      ]),
    );
  }

  void openHistoryDrawer(BuildContext context, ScreenSize screenSize) {
    openSheet(
      context: context,
      transformBackdrop: false,
      builder: (context) {
        return buildHistoryList(context, screenSize);
      },
      position: OverlayPosition.right,
    );
  }

  Widget buildHistoryList(BuildContext context, ScreenSize screenSize) {
    return Container(
      width: screenSize == ScreenSize.small ? 150 : null,
      margin: EdgeInsets.only(top: 0, right: 0, bottom: 0),
      child: HistoryList(
        onSelected: (conversation) {
          controller!.conversation = conversation;
          getConversationMessages();
        },
        onRenameDone: (conversation) {
          getHistory();
        },
        onNewConversation:
            screenSize == ScreenSize.small ? null : onNewConversation,
        onDeleteConversation: (conversation) {
          if (conversation == controller!.conversation) {
            controller!.conversation = null;
          }
          getHistory();
          getConversationMessages();
        },
      ),
    );
  }

  void onNewConversation() {
    if (controller!.conversation == null) {
      showToast(
        context: context,
        showDuration: Duration(seconds: 2),
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              leading: Icon(BootstrapIcons.info),
              title: const Text('已在新对话中'),
              trailingAlignment: Alignment.center,
            ),
          );
        },
        location: ToastLocation.topRight,
      );
      return;
    }
    if (subscription != null) {
      subscription!.cancel();
      done = true;
    }
    controller!.conversation = null;
    getConversationMessages();
  }

  void getConversationMessages() async {
    if (controller!.conversation == null) {
      setState(() {
        orderedMessages = [];
      });
      return;
    }
    List<Message> messages =
        await Message.getConversationMessage(controller!.conversation!.id!);
    setState(
      () {
        orderedMessages = messages;
      },
    );
  }

  List<Message> getCurrentModelMessages(String model) {
    List<Message> res = [];
    orderedMessages.forEach((item) {
      if (item.model == model) {
        res.add(item);
      }
    });
    return res;
  }

  Future<void> chat(BuildContext context, String message) async {
    String chatModel = model!;
    // 取消对话
    if (done == false && subscription != null && userMsg != null) {
      subscription!.cancel();
      setState(() {
        done = true;
        subscription = null;
      });
      await Message.insertMessage(userMsg!);
      if (controller!.conversation != null) {
        Message assistantMsg = Message(
            content: responseBuffer.toString(),
            thinkContent: thinkBuffer.toString(),
            conversationId: controller!.conversation!.id!,
            role: 1,
            model: chatModel);
        await Message.insertMessage(assistantMsg);
        thinkBuffer.clear();
        responseBuffer = StringBuffer();
      }
      return;
    }
    // 配置apiKey
    String? _apiKey = await _storage.read(key: "apiKey");
    setState(() {
      apiKey = _apiKey;
    });

    if (apiKey == null ||
        apiKey!.isEmpty ||
        !apiKey!.startsWith(RegExp("sk-"))) {
      showAlert(context,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                BootstrapIcons.exclamationCircle,
                color: Colors.orange,
              ),
              SizedBox(width: 10),
              Text("API Key 未设置")
            ],
          ),
          content: Text("api_key_note2".tr()), onConfirm: () {
        showApiKeyDialog(context, onEnd: (success) {
          if (success) {
            showToast(
              context: context,
              location: ToastLocation.bottomRight,
              showDuration: Duration(seconds: 2),
              builder: buildToast,
            );
          }
        });
      });
      return;
    }
    OpenAI.apiKey = apiKey!;

    if (model == null || message.isEmpty) {
      showToast(
          context: context,
          location: ToastLocation.topRight,
          showDuration: Duration(seconds: 2),
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                leading: Icon(BootstrapIcons.exclamationCircle),
                content: Text("请选择模型并输入内容"),
              ),
            );
          });
      return;
    }
    setState(() {
      done = false;
    });
    if (controller!.conversation == null) {
      controller!.conversation = Conversation(title: message);
      int id = await controller!.conversation!.save();
      controller!.conversation =
          Conversation(id: id, title: controller!.conversation!.title);
      if (controller!.conversation!.id == null) {
        return;
      }

      controller!.histories = [
        controller!.conversation!,
        ...controller!.histories
      ];
      controller!.conversation = controller!.conversation;
    }
    userMsg = Message(
        content: message,
        conversationId: controller!.conversation!.id!,
        role: 0,
        model: model!);
    setState(() {
      orderedMessages.add(userMsg!);
    });

    List<Message> messages = getCurrentModelMessages(chatModel);
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages = [];
    messages.forEach((element) {
      modelMessages.add(OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              element.content,
            )
          ],
          role: element.role == 0
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          name: chatModel));
    });
    final chatStream = OpenAI.instance.chat.createStream(
      model: chatModel,
      messages: modelMessages,
    );
    setState(() {
      orderedMessages.add(Message(
          content: "",
          conversationId: controller!.conversation!.id!,
          role: 1,
          model: chatModel));
    });
    subscription = chatStream.listen((streamChatCompletion) {
      final content = streamChatCompletion.choices.first.delta.content;
      content?.forEach((item) {
        if (item != null) {
          messages = getCurrentModelMessages(chatModel);
          var text = item.text;
          if (text!.contains(RegExp("<think>"))) {
            setState(() {
              isThinking = true;
            });
            text = text.replaceFirst(RegExp("<think>"), "");
            thinkBuffer.write(text);
          } else if (text.contains("</think>")) {
            setState(() {
              isThinking = false;
            });
            var parts = text.split("</think>");
            if (parts.length == 2) {
              if (parts[1].trim().isNotEmpty) {
                thinkBuffer.write(parts[0]);
              } else {
                thinkBuffer.write(parts[0]);
                responseBuffer.write(parts[1]);
              }
            }
          } else {
            if (isThinking) {
              thinkBuffer.write(text);
            } else {
              responseBuffer.write(text);
            }
            Message assistantMsg = Message(
                content: responseBuffer.toString(),
                thinkContent: thinkBuffer.toString().trim().isEmpty
                    ? null
                    : thinkBuffer.toString(),
                conversationId: controller!.conversation!.id!,
                role: 1,
                model: chatModel);
            setState(() {
              orderedMessages[orderedMessages.length - 1] = assistantMsg;
            });
            if (autoScroll) {
              _msgScrollController
                  .jumpTo(_msgScrollController.position.maxScrollExtent);
            }
          }
        }
      });
    }, onDone: () async {
      await Message.insertMessage(userMsg!);
      Message assistantMsg = Message(
          content: responseBuffer.toString(),
          thinkContent: thinkBuffer.toString(),
          conversationId: controller!.conversation!.id!,
          role: 1,
          model: chatModel);
      await Message.insertMessage(assistantMsg);
      setState(() {
        done = true;
        subscription = null;
      });
      thinkBuffer.clear();
      responseBuffer.clear();
    }, onError: (error) {
      showToast(
        context: context,
        location: ToastLocation.topCenter,
        showDuration: Duration(seconds: 2),
        builder: (context, overlay) {
          return Alert.destructive(
            title: Text('错误'),
            content: Text(error.toString()),
            trailing: Icon(Icons.dangerous_outlined),
          );
        },
      );
    });
  }
}
