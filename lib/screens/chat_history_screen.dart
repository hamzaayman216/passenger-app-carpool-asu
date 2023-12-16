import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/components/message_stream.dart';

class ChatHistoryScreen extends StatefulWidget {
  static const String id = 'driver_chat_screen';
  final String rideId;
  final User loggedInUser;

  ChatHistoryScreen({required this.rideId,required this.loggedInUser});

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final messageTextController = TextEditingController();
  late String messageText;

  @override
  void initState() {
    super.initState();
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
        iconTheme: IconThemeData(color: kSecondaryColor),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              rideId: widget.rideId,
              loggedInUser: widget.loggedInUser,
            ),
          ],
        ),
      ),
    );
  }
}