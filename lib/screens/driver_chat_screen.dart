import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/components/message_stream.dart';

final _database = FirebaseDatabase.instance.reference();
final _auth = FirebaseAuth.instance;
late User loggedInUser;

class DriverChatScreen extends StatefulWidget {
  static const String id = 'driver_chat_screen';
  final String rideId;

  DriverChatScreen({required this.rideId});

  @override
  _DriverChatScreenState createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  final messageTextController = TextEditingController();
  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage() {
    // Update this method to send messages to the chat specific to the ride
    messageText = messageTextController.text.trim();
    if (messageText.isNotEmpty) {
      _database.child('rides/${widget.rideId}/chat').push().set({
        'text': messageText,
        'sender': loggedInUser.email,
        'timestamp': ServerValue.timestamp, // Add this line to include the timestamp
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
              loggedInUser: loggedInUser,
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
