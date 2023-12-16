import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carpool/models/user.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<CarPoolUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
        Query query = usersRef.orderByChild('email').equalTo(user.email);

        DataSnapshot snapshot = await query.get();
        if (snapshot.exists && snapshot.value != null) {
          Map<dynamic, dynamic>? data =
          snapshot.value as Map<dynamic, dynamic>?;
          if (data != null && data.containsKey(user.uid)) {
            var userData = data[user.uid] as Map<dynamic, dynamic>;
            return CarPoolUser.fromMap(Map<String, dynamic>.from(userData));
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    DatabaseReference usersRef =
    FirebaseDatabase.instance.ref('users').child(driverId);
    DatabaseEvent event = await usersRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> userData =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      return userData;
    }else{
      return null;
    }
  }

  Future<List<CarPoolUser>> fetchPassengers(Ride ride) async {
    List<CarPoolUser> passengers = [];
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');

    for (String passengerId in ride.passengerIds ?? []) {
      DataSnapshot snapshot = await usersRef.child(passengerId).get();

      if (snapshot.exists) {
        Map<String, dynamic> userData =
        Map<String, dynamic>.from(snapshot.value as Map);
        CarPoolUser user = CarPoolUser.fromMap(
            userData);
        passengers.add(user);
      }
    }
    return passengers;
  }



}