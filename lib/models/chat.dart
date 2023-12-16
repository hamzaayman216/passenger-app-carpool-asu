class ChatMessage {
  String messageId;
  String senderId;
  String text;
  int timestamp;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String messageId) {
    return ChatMessage(
      messageId: messageId,
      senderId: map['senderId'],
      text: map['text'],
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
