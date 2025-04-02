import 'dart:async';

import 'package:chatfusion/database/models/conversation.dart';
import 'package:chatfusion/database/models/message.dart';
import 'package:chatfusion/pages/chat/chat_input.dart';
import 'package:chatfusion/pages/chat/history.dart';
import 'package:chatfusion/pages/chat/history_list.dart';
import 'package:chatfusion/pages/settings/api_key.dart';
import 'package:chatfusion/utils/item.dart';
import 'package:chatfusion/widgets/dialog.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
  Conversation? conversation;
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
  List<Conversation> histories = [];
  StringBuffer responseBuffer = StringBuffer();
  StringBuffer thinkBuffer = StringBuffer();
  Message? userMsg;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? apiKey;
  @override
  void initState() {
    super.initState();
    model = supportModels.keys.first;
    OpenAI.baseUrl = "https://dashscope.aliyuncs.com/compatible-mode";
    getHistory();
  }

  void getHistory() async {
    var res = await Conversation.getConversations(asc: false);
    setState(() {
      histories = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResizablePanel.horizontal(
      draggerBuilder: (context) {
        return const HorizontalResizableDragger();
      },
      children: [
        ResizablePane(
          initialSize: 150,
          minSize: 120,
          maxSize: 250,
          child: Container(
            margin: EdgeInsets.only(top: 0, right: 0, bottom: 0),
            child: HistoryList(
              histories: histories,
              selected: conversation,
              onSelected: (conversation) {
                setState(() {
                  this.conversation = conversation;
                });
                getConversationMessages();
              },
              onRenameDone: (conversation) {
                getHistory();
              },
              onNewConversation: () {
                if (conversation == null) {
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
                setState(() {
                  conversation = null;
                });
                getConversationMessages();
              },
              onDeleteConversation: (conversation) {
                if (conversation == this.conversation) {
                  setState(() {
                    this.conversation = null;
                  });
                }
                getHistory();
                getConversationMessages();
              },
            ),
          ),
        ),
        ResizablePane.flex(
          minSize: 350,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(conversation != null
                          ? conversation!.title
                          : 'new_chat'.tr())
                      .h4,
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
                  model: model,
                  done: done,
                  onModelChange: (v) {
                    setState(() {
                      model = v;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void getConversationMessages() async {
    if (conversation == null) {
      setState(() {
        orderedMessages = [];
      });
      return;
    }
    List<Message> messages =
        await Message.getConversationMessage(conversation!.id!);
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

      Message assistantMsg = Message(
          content: responseBuffer.toString(),
          thinkContent: thinkBuffer.toString(),
          conversationId: conversation!.id!,
          role: 1,
          model: chatModel);
      await Message.insertMessage(assistantMsg);
      thinkBuffer.clear();
      responseBuffer = StringBuffer();
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
    if (conversation == null) {
      conversation = Conversation(title: message);
      int id = await conversation!.save();
      conversation = Conversation(id: id, title: conversation!.title);
      if (conversation!.id == null) {
        return;
      }
      setState(() {
        histories = [conversation!, ...histories];
        conversation = conversation;
      });
    }
    userMsg = Message(
        content: message,
        conversationId: conversation!.id!,
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
          conversationId: conversation!.id!,
          role: 1,
          model: chatModel));
    });
    subscription = chatStream.listen(
      (streamChatCompletion) {
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
                  conversationId: conversation!.id!,
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
      },
      onDone: () async {
        await Message.insertMessage(userMsg!);
        Message assistantMsg = Message(
            content: responseBuffer.toString(),
            thinkContent: thinkBuffer.toString(),
            conversationId: conversation!.id!,
            role: 1,
            model: chatModel);
        await Message.insertMessage(assistantMsg);
        setState(() {
          done = true;
          subscription = null;
        });
        thinkBuffer.clear();
        responseBuffer.clear();
      },
    );
  }
}
