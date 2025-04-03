import 'package:chatfusion/database/models/conversation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ChatController extends ChangeNotifier {
  Conversation? _conversation;
  List<Conversation> _histories = [];
  Conversation? _renameConversation;
  Conversation? get conversation => _conversation;
  List<Conversation> get histories => _histories;
  Conversation? get renameConversation => _renameConversation;

  set renameConversation(Conversation? value) {
    _renameConversation = value;
    notifyListeners();
  }

  set histories(List<Conversation> value) {
    _histories = value;
    notifyListeners();
  }

  set conversation(Conversation? value) {
    _conversation = value;
    notifyListeners();
  }

  void addConversation(Conversation conversation) {
    _histories.add(conversation);
    notifyListeners();
  }

  void removeConversation(Conversation conversation) {
    _histories.remove(conversation);
    notifyListeners();
  }
}
