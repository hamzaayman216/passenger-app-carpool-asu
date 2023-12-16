import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carpool/components/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesStream extends StatelessWidget {
  final String rideId;
  final User loggedInUser;

  MessagesStream({required this.rideId, required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    final messageReference = FirebaseDatabase.instance.reference().child('rides/$rideId/chat');

    return StreamBuilder<DatabaseEvent>(
      stream: messageReference.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final messagesMap = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          List<MessageBubble> messageBubbles = [];

          List<MapEntry<String, dynamic>> sortedMessages = messagesMap.entries.toList()
            ..sort((a, b) {
              final timestampA = a.value['timestamp'] as int?;
              final timestampB = b.value['timestamp'] as int?;
              if (timestampA == null || timestampB == null) {
                return 0;
              }
              return timestampA.compareTo(timestampB);
            });

          for (var entry in sortedMessages) {
            final messageData = entry.value;
            final messageText = messageData['text'] as String?;
            final messageSender = messageData['sender'] as String?;
            final currentUser = loggedInUser.email;

            if (messageText != null && messageSender != null) {
              final messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,
              );

              messageBubbles.add(messageBubble);
            }
          }

          return Expanded(
            child: ListView(
              reverse: false,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        } else {
          return Center(
            child: Text('No messages'),
          );
        }
      },
    );
  }
}
