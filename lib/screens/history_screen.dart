import 'package:carpool/components/history_list.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

late User loggedInUser;

class HistoryScreen extends StatefulWidget {
  static const String id = 'driver_screen';

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text('My History', style: TextStyle(color: Colors.black)),
        elevation: 20,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kSecondaryColor),
      ),
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('rides').onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return Center(child: Text('No rides available', style: TextStyle(color: Colors.red, fontSize: 20)));
            } else {
              // Extracting data from snapshot
              var ridesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              // Converting the map to a list of Ride objects
              List<Ride> rides = [];
              ridesMap.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  var rideMap = Map<String, dynamic>.from(value);
                  var ride = Ride.fromMap(rideMap);
                  if (ride.passengerIds!.contains(loggedInUser.uid)  &&ride.status=='Finished') { // Check for driverId instead of driver's email
                    rides.add(ride);
                  }
                }
              });

              return HistoryList(ridesStream: Stream.fromIterable([rides]));
            }
          },
        ),
      ),
    );
  }
}