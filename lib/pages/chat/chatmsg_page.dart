import 'package:fishapp/config/themes/theme_config.dart';
import 'package:fishapp/entities/chat/conversation.dart';
import 'package:fishapp/entities/chat/message.dart';
import 'package:fishapp/entities/chat/messagebody.dart';
import 'package:fishapp/entities/user.dart';
import 'package:fishapp/utils/default_builder.dart';
import 'package:fishapp/utils/services/rest_api_service.dart';
import 'package:fishapp/utils/state/appstate.dart';
import 'package:fishapp/widgets/nav_widgets/common_nav.dart';
import 'package:fishapp/widgets/standard_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:provider/provider.dart';

import 'conversation_model.dart';

class ChatMessagePage extends StatefulWidget {
  final Conversation baseConversation;

  ChatMessagePage({Key key, @required this.baseConversation}) : super(key: key);

  @override
  _ChatMessagePageState createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  final ConversationService _conversationService = ConversationService();
  final _scrollController = ScrollController();
  //final List<Message> messages = List();
  //Conversation conversation = Conversation();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //this.conversation = widget.baseConversation;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //Provider.of<ConversationModel>(context, listen: false).clear();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConversationModel(context, widget.baseConversation),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
            child: getFishappDefaultScaffold(context,
                includeTopBar: widget.baseConversation.listing.creator.name,
                extendBehindAppBar: false, child: Consumer<AppState>(
          builder: (context, userdata, child) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CHAT MESSAGE LISTS
                Expanded(
                  child: appFutureBuilder<List<Message>>(
                      _conversationService.getMessageUpdates(
                          context, widget.baseConversation.id, null),
                      (messagesFromServer, context) {
                    print("FUTURE builder: from srv result " +
                        messagesFromServer.length.toString());
                    //this.messages.addAll(messagesFromServer);
                    Provider.of<ConversationModel>(context, listen: false)
                        .initMessages(messagesFromServer);

                    return Consumer<ConversationModel>(
                      builder: (context, model, child) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            itemCount: model.messages.length,
                            itemBuilder: (context, index) {
                              // scroll to bottom
                              // https://stackoverflow.com/a/58924439
                              final reversedIndex =
                                  model.messages.length - 1 - index;
                              final message = model.messages[reversedIndex];
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: ChatBubbleFromMessage(
                                  message: message,
                                  loggedInUserId: userdata.user.id,
                                ),
                              );
                            }),
                      ),
                    );
                  }),
                ),
                // CHAT WRITE MESSAGE BAR
                SendChatMessageForm(),
                //
                // DEBUG BUTTONS
                StandardButton(
                    buttonText: "refresh",
                    onPressed: () {
                      Provider.of<ConversationModel>(context, listen: false)
                          .reloadMessages();
                    }),
                StandardButton(
                    buttonText: "ned",
                    onPressed: () {
                      _scrollController.animateTo(
                          _scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn);
                    }),
              ],
            );
          },
        ))),
      ),
    );
  }
}

class SendChatMessageForm extends StatefulWidget {
  @override
  _SendChatMessageFormState createState() => _SendChatMessageFormState();
}

class _SendChatMessageFormState extends State<SendChatMessageForm> {
  final textEditController = TextEditingController();
  bool isMessageValid = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditController.addListener(_validateMessageInput);
  }

  _validateMessageInput() {
    setState(() {
      if (textEditController.text.isNotEmpty) {
        isMessageValid = true;
      } else {
        isMessageValid = false;
      }
    });
  }

  void sendMessage() {
    MessageBody mbody =
        MessageBody(messageText: textEditController.text.toString());
    textEditController.clear();
    Provider.of<ConversationModel>(context, listen: false).sendMessage(mbody);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.camera_alt), onPressed: null),
          Flexible(
            child: TextField(
              controller: textEditController,
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: StandardButton(
                  buttonText: "Send",
                  onPressed: isMessageValid ? sendMessage : null)),
        ],
      ),
    );
  }
}

class ChatBubbleFromMessage extends StatelessWidget {
  final Message message;
  final num loggedInUserId;

  const ChatBubbleFromMessage(
      {Key key, @required this.message, @required this.loggedInUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Drawing message id:" + message.id.toString());

    return ChatBubble(
      //margin: EdgeInsets.only(top: 20),
      backGroundColor: _isSenderLoggedInUser(message)
          ? Color(0xff354ff6)
          : Color(0xffE7E7ED),
      alignment: _isSenderLoggedInUser(message)
          ? Alignment.topRight
          : Alignment.topLeft,
      clipper: ChatBubbleClipper5(
        type: _isSenderLoggedInUser(message)
            ? BubbleType.sendBubble
            : BubbleType.receiverBubble,
      ),
      child: Text(message.content,
          style: TextStyle(
              color: _isSenderLoggedInUser(message)
                  ? Colors.white
                  : Colors.black)),
    );
  }

  bool _isSenderLoggedInUser(Message message) {
    if (loggedInUserId == message.senderId) {
      return true;
    } else {
      return false;
    }
  }
}