import 'package:carpool/models/chat.dart';
class Ride {
  final String driverId; // Changed to driverId of type String
  final String startPoint;
  final String endPoint;
  final String date;
  final String time;
  List<String>? passengerIds;
  final String id;
  bool confirmed = false;
  final int numberOfPassengers;
  List<dynamic> preferences;
  List<ChatMessage>? chatMessages;
  final String status;

  Ride({
    required this.driverId, // Updated
    required this.time,
    required this.date,
    required this.endPoint,
    required this.startPoint,
    this.passengerIds,
    required this.id,
    required this.confirmed,
    required this.numberOfPassengers,
    required this.preferences,
    required this.chatMessages,
    required this.status
  });

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      driverId: map['driverId'] as String,
      confirmed: map['confirmed'] as bool,
      id: map['id'] as String,
      time: map['time'] as String,
      date: map['date'] as String,
      endPoint: map['endPoint'] as String,
      startPoint: map['startPoint'] as String,
      numberOfPassengers: map['numberOfPassengers'] as int,
      preferences: map['preferences'] != null ? List<dynamic>.from(map['preferences']) : [],
      passengerIds: (map['passengerIds'] as List<dynamic>?)?.map((item) => item as String).toList() ?? [],
      chatMessages: (map['chatMessages'] as List<dynamic>?)?.map((item) => ChatMessage.fromMap(item as Map<String, dynamic>, item['messageId'] as String)).toList() ?? [],
      status: map['status'] as String,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId, // Updated
      'confirmed': confirmed,
      'id': id,
      'time': time,
      'date': date,
      'endPoint': endPoint,
      'startPoint': startPoint,
      'numberOfPassengers': numberOfPassengers,
      'preferences': preferences,
      'passengerIds': passengerIds,
      'chatMessages':chatMessages,
      'status':status,
    };
  }
}
