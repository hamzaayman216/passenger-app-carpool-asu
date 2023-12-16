import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/components/message_stream.dart';

final _database = FirebaseDatabase.instance.reference();
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final String rideId;
  final User loggedInUser;


  ChatScreen({required this.rideId,required this.loggedInUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  late String messageText;

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() {
    messageText = messageTextController.text.trim();
    if (messageText.isNotEmpty) {
      _database.child('rides/${widget.rideId}/chat').push().set({
        'text': messageText,
        'sender': widget.loggedInUser.email,
        'timestamp': ServerValue.timestamp,
      });
      messageTextController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: Text('Chat',style: TextStyle(color: kSecondaryColor),),
        elevation: 20,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kSecondaryColor),      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              rideId: widget.rideId,
              loggedInUser: widget.loggedInUser,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                          hintStyle: TextStyle(color: Colors.black)),
                    ),
                  ),
                  TextButton(
                    onPressed: _sendMessage,
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}