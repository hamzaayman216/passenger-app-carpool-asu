import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class PaymentStatusService {
  Future<bool> getPaidStatus(String email, String rideId) async {
    try {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
      Query userQuery = usersRef.orderByChild('email').equalTo(email);
      String userId = '';
      DataSnapshot userSnapshot = await userQuery.get();
      if (userSnapshot.exists) {
        Map<dynamic, dynamic> userData = userSnapshot.value as Map<dynamic, dynamic>;
        userId = userData.keys.first; // Assuming email is unique and we get one result
      }
      DatabaseReference paidStatusRef = FirebaseDatabase.instance.ref('paidStatus');
      Query paidStatusQuery = paidStatusRef.orderByChild('userId').equalTo(userId);
      Completer<bool> completer = Completer<bool>();
      paidStatusQuery.onValue.listen((event) {
        if (event.snapshot.value == null) {
          completer.complete(false);
        } else {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          var filteredData = data.values.where((entry) => entry['rideId'] == rideId).toList();
          if (filteredData.isNotEmpty && filteredData.first['paid'] == true) {
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      });
      return completer.future;
    } catch (e) {
      return false;
    }
  }
}