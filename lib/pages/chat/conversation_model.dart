import 'dart:collection';

import 'package:fishapp/entities/chat/conversation.dart';
import 'package:fishapp/entities/chat/message.dart';
import 'package:fishapp/entities/chat/messagebody.dart';
import 'package:fishapp/utils/services/rest_api_service.dart';
import 'package:flutter/widgets.dart';

class ConversationModel extends ChangeNotifier {
  final _buildContext;
  final _conversationService = ConversationService();
  final List<Message> _messages = List();

  Conversation _currentConversation;
  bool _sendMessageErrorIsPresent = false;
  MessageBody _lastFailedSendMessage = MessageBody();

  ConversationModel(this._buildContext, this._currentConversation);

  UnmodifiableListView<Message> get messages => UnmodifiableListView(_messages);
  Conversation get conversation => (this._currentConversation);
  bool get sendMessageErrorOccurred => (this._sendMessageErrorIsPresent);
  MessageBody get lastFailedSendMessage => (this._lastFailedSendMessage);

  void initMessages(List<Message> messages) {
    this._messages.clear();
    this._messages.addAll(messages);
  }

  void clear() {
    this._messages.clear();
    this._currentConversation.firstMessageId = 0;
    this._currentConversation.lastMessageId = 0;
    notifyListeners();
  }

  void clearErrorState() {
    this._sendMessageErrorIsPresent = false;
    this._lastFailedSendMessage = MessageBody();
    notifyListeners();
  }

  Future<List<Message>> loadMessages(
      BuildContext context, num conversationId) async {
    return await _conversationService.getMessageUpdates(
        context, conversationId, null);
  }

  Future<void> reloadAllMessages() async {
    List<Message> reloadResult = List();
    reloadResult = await _conversationService.getMessageUpdates(
        this._buildContext, this._currentConversation.id, null);
    if (reloadResult.isNotEmpty) {
      this._messages.clear();
      this._messages.addAll(reloadResult);
      notifyListeners();
    }
  }

  Future<void> sendMessage(MessageBody message) async {
    try {
      Conversation result = await _conversationService.sendMessageRequest(
          this._buildContext, this._currentConversation.id, message);
      if (result != null) {
        print('MODEL: Sendt message OK');
        _sendMessageErrorIsPresent = false;
        _lastFailedSendMessage = MessageBody();
        this._loadNewMessages(this._currentConversation, result);
      } else {
        _sendMessageErrorIsPresent = true;
        _lastFailedSendMessage = message;
        notifyListeners();
      }
    } on Exception {
      _sendMessageErrorIsPresent = true;
      _lastFailedSendMessage = message;
      notifyListeners();
    }
  }

  Future<void> _loadNewMessages(
      Conversation metadataInApp, Conversation metadataFromServer) async {
    num lastLocalMsgId = metadataInApp.lastMessageId; // 5
    num lastServerMsgId = metadataFromServer.lastMessageId; //6
    print('MODEL: last msgs id local:server = ' +
        lastLocalMsgId.toString() +
        ':' +
        lastServerMsgId.toString());
    List<Message> tailMessageListResult = List();
    try {
      tailMessageListResult = await _conversationService.getMessageUpdates(
          this._buildContext, metadataInApp.id, lastLocalMsgId);
      if (tailMessageListResult != null && tailMessageListResult.isNotEmpty) {
        print('MODEL: Added ' +
            tailMessageListResult.length.toString() +
            'messages from server.');
        this._messages.addAll(tailMessageListResult);
        this._currentConversation = metadataFromServer;
        notifyListeners();
      }
    } on Exception catch (e) {}
  }
}
