import 'package:carpool/components/rides_list.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/controller/services/user_service.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/models/user.dart';
import 'package:carpool/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

late User loggedInUser;

class PassengerScreen extends StatefulWidget {
  static const String id = 'passenger_screen';

  @override
  _PassengerScreenState createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  UserService userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CarPoolUser querySnapshot = CarPoolUser(name: '', email: '', phoneNumber: '', imageUrl: '',balance: 0);
  Stream<List<Ride>> ridesStream = Stream.empty();


  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser!;
    initUser();
  }

  void initUser() async {
    CarPoolUser? user = await userService.getCurrentUser();
    if (user != null) {
      setState(() {
        querySnapshot = user;
      });
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