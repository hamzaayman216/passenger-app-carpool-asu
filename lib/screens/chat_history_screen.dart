import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/components/message_stream.dart';

final _database = FirebaseDatabase.instance.reference();
final _auth = FirebaseAuth.instance;
late User loggedInUser;

class ChatHistoryScreen extends StatefulWidget {
  static const String id = 'driver_chat_screen';
  final String rideId;

  ChatHistoryScreen({required this.rideId});

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
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
              loggedInUser: loggedInUser,
            ),
          ],
        ),
      ),
    );
  }
}
