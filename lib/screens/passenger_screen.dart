import 'package:carpool/components/rides_list.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/models/user.dart';
import 'package:carpool/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

late User loggedInUser;

class PassengerScreen extends StatefulWidget {
  static const String id = 'passenger_screen';

  @override
  _PassengerScreenState createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CarPoolUser querySnapshot = CarPoolUser(name: '', email: '', phoneNumber: '', imageUrl: '',balance: 0);

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
        Query query = usersRef.orderByChild('email').equalTo(loggedInUser.email);

        DataSnapshot snapshot = await query.get();
        if (snapshot.exists && snapshot.value != null) {
          Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
          if (data != null && data.containsKey(user.uid)) {
            var userData = data[user.uid] as Map<dynamic, dynamic>;
            querySnapshot = CarPoolUser.fromMap(Map<String, dynamic>.from(userData));
            setState(() {}); // Call setState to update the UI
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Ride>> ridesStream = FirebaseDatabase.instance
        .ref('rides')
        .onValue
        .map((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<Ride> rides = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            Ride ride = Ride.fromMap(Map<String, dynamic>.from(value));
            if (ride.driverId != loggedInUser.uid &&ride.status!='Finished') { // Use driverId for comparison
              rides.add(ride);
            }
          }
        });
        return rides;
      } else {
        return <Ride>[];
      }
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          title: Text('Available Rides', style: TextStyle(color: kSecondaryColor)),
          elevation: 20,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: kSecondaryColor),
        ),
        drawer: querySnapshot == null ? null : ProfileScreen(user: querySnapshot),
        body: SafeArea(
          child: RideList(ridesStream: ridesStream),
        ),
      ),
    );
  }
}
