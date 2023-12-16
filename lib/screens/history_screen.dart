import 'package:carpool/components/history_list.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/controller/services/ride_services.dart';
import 'package:carpool/controller/services/user_service.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

late User loggedInUser;

class HistoryScreen extends StatefulWidget {
  static const String id = 'history_screen';

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserService userService = UserService();
  CarPoolUser querySnapshot = CarPoolUser(name: '', email: '', phoneNumber: '', imageUrl: '',balance: 0);

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
              List<Ride> rides = RidesService().getHistoryRides(snapshot.data!, loggedInUser.uid);

              return HistoryList(ridesStream: Stream.fromIterable([rides]));
            }
          },
        ),
      ),
    );
  }
}